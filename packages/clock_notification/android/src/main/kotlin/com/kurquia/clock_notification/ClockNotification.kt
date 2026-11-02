package com.kurquia.clock_notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import org.json.JSONObject
import java.util.Locale

/**
 * What the notification shows. The clock ticks from [ticksFrom] (ms since the epoch: up from it,
 * or down to it if [countDown]); with [ticksFrom] null it stands at [stoppedMs]. [text] is the
 * line under it, [button] the Pause/Resume label, [action] its id for the app's handler.
 * [redrawn]: plain text rewritten every second by [ClockService], instead of a live clock line.
 */
data class Content(
    val title: String,
    val text: String,
    val ticksFrom: Long?,
    val countDown: Boolean,
    val stoppedMs: Long,
    val button: String,
    val action: String,
    val icon: String,
    val redrawn: Boolean,
) {
    fun toJson() = JSONObject()
        .put("title", title).put("text", text).put("ticksFrom", ticksFrom)
        .put("countDown", countDown).put("stoppedMs", stoppedMs).put("button", button)
        .put("action", action).put("icon", icon).put("redrawn", redrawn)

    /** The clock as text at [now], like the app's formatClock: 1:02:03 or 12:03. */
    fun clockText(now: Long): String {
        val ms = when {
            ticksFrom == null -> stoppedMs
            countDown -> maxOf(0, ticksFrom - now + 999)
            else -> now - ticksFrom
        }
        val s = ms / 1000
        val (h, m, sec) = Triple(s / 3600, s / 60 % 60, s % 60)
        return if (h > 0) String.format(Locale.ROOT, "%d:%02d:%02d", h, m, sec)
        else String.format(Locale.ROOT, "%d:%02d", m, sec)
    }

    companion object {
        fun from(m: Map<*, *>) = Content(
            title = m["title"] as String,
            text = m["text"] as String,
            ticksFrom = (m["ticksFrom"] as Number?)?.toLong(),
            countDown = m["countDown"] as Boolean,
            stoppedMs = (m["stoppedMs"] as Number).toLong(),
            button = m["button"] as String,
            action = m["action"] as String,
            icon = m["icon"] as String,
            redrawn = m["redrawn"] as Boolean,
        )

        fun fromJson(j: JSONObject) = Content(
            title = j.getString("title"),
            text = j.getString("text"),
            ticksFrom = if (j.isNull("ticksFrom")) null else j.getLong("ticksFrom"),
            countDown = j.getBoolean("countDown"),
            stoppedMs = j.getLong("stoppedMs"),
            button = j.getString("button"),
            action = j.getString("action"),
            icon = j.getString("icon"),
            redrawn = j.getBoolean("redrawn"),
        )
    }
}

object ClockNotification {
    const val ID = 1
    private const val CHANNEL = "workout"
    private const val PREFS = "clock_notification"
    private const val KEY = "content"

    // flutter_local_notifications' receiver runs the app's Dart handler for a button, also with
    // the app closed (onDidReceiveBackgroundNotificationResponse).
    private const val ACTION_RECEIVER =
        "com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver"

    fun show(context: Context, content: Content) {
        // Kept so the service can redraw on its own, also after Android restarts it.
        prefs(context).edit().putString(KEY, content.toJson().toString()).apply()
        if (content.redrawn) {
            ClockService.start(context)
        } else {
            ClockService.detach()
            notify(context, content)
        }
    }

    fun cancel(context: Context) {
        prefs(context).edit().remove(KEY).apply()
        ClockService.stop()
        manager(context).cancel(ID)
    }

    fun load(context: Context): Content? =
        prefs(context).getString(KEY, null)?.let { Content.fromJson(JSONObject(it)) }

    fun notify(context: Context, content: Content) =
        manager(context).notify(ID, build(context, content))

    fun build(context: Context, c: Content): android.app.Notification {
        ensureChannel(context)
        val b = NotificationCompat.Builder(context, CHANNEL)
            .setSmallIcon(
                context.resources.getIdentifier(c.icon, "drawable", context.packageName)
            )
            .setContentTitle(c.title)
            .setOngoing(true)
            .setSilent(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setCategory(NotificationCompat.CATEGORY_STOPWATCH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .setContentIntent(openApp(context))
            .addAction(0, c.button, button(context, c.action))
        if (c.redrawn) {
            val lines = listOf(c.clockText(System.currentTimeMillis()), c.text)
                .filter { it.isNotEmpty() }
            b.setContentText(lines.joinToString(" · "))
                .setStyle(NotificationCompat.BigTextStyle().bigText(lines.joinToString("\n")))
        } else {
            b.setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setCustomContentView(views(context, c, R.layout.clock_notification))
                .setCustomBigContentView(views(context, c, R.layout.clock_notification_big))
        }
        return b.build()
    }

    /** Title, the live clock (an Android Chronometer, ticked by the system) and the text. */
    private fun views(context: Context, c: Content, layout: Int) =
        RemoteViews(context.packageName, layout).apply {
            val hidden = if (c.text.isEmpty()) View.GONE else View.VISIBLE
            setTextViewText(R.id.title, c.title)
            setTextViewText(R.id.text, c.text)
            setViewVisibility(R.id.text, hidden)
            setViewVisibility(R.id.separator, hidden)
            // The Chronometer counts on the uptime clock, not the wall clock.
            val now = SystemClock.elapsedRealtime()
            if (c.ticksFrom != null) {
                setChronometer(
                    R.id.clock, now + c.ticksFrom - System.currentTimeMillis(), null, true
                )
            } else {
                setChronometer(R.id.clock, now - c.stoppedMs, null, false)
            }
            setChronometerCountDown(R.id.clock, c.ticksFrom != null && c.countDown)
        }

    private fun openApp(context: Context): PendingIntent? =
        context.packageManager.getLaunchIntentForPackage(context.packageName)?.let {
            PendingIntent.getActivity(context, ID, it, FLAGS)
        }

    private fun button(context: Context, action: String): PendingIntent {
        val intent = Intent()
            .setClassName(context, ACTION_RECEIVER)
            .setAction("$ACTION_RECEIVER.ACTION_TAPPED")
            .putExtra("notificationId", ID)
            .putExtra("actionId", action)
            .putExtra("cancelNotification", false)
        return PendingIntent.getBroadcast(context, ID * 16, intent, FLAGS)
    }

    /** The silent "Workout clock" channel (as flutter_local_notifications created it before). */
    private fun ensureChannel(context: Context) {
        val m = manager(context)
        if (m.getNotificationChannel(CHANNEL) != null) return
        m.createNotificationChannel(
            NotificationChannel(CHANNEL, "Workout clock", NotificationManager.IMPORTANCE_LOW).apply {
                description = "The open workout's clock and rest"
                setSound(null, null)
                enableVibration(false)
                setShowBadge(false)
            }
        )
    }

    private fun manager(context: Context) =
        context.getSystemService(NotificationManager::class.java)

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private val FLAGS = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
}
