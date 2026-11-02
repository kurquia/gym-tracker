package com.kurquia.clock_notification

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

/**
 * The "redrawn" style: rewrites the notification text every second. Being a foreground service
 * keeps the app's process alive, but a phone that kills it anyway (MIUI) freezes the clock.
 */
class ClockService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val tick = Runnable { redraw() }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val content = ClockNotification.load(this)?.takeIf { it.redrawn }
        if (content == null) {
            stopSelf()
            return START_NOT_STICKY
        }
        instance = this
        ServiceCompat.startForeground(
            this,
            ClockNotification.ID,
            ClockNotification.build(this, content),
            if (Build.VERSION.SDK_INT >= 34) ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE else 0,
        )
        schedule(content)
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(tick)
        if (instance === this) instance = null
        super.onDestroy()
    }

    private fun redraw() {
        val content = ClockNotification.load(this) ?: return
        ClockNotification.notify(this, content)
        schedule(content)
    }

    /** Next redraw just after the clock's next whole second. */
    private fun schedule(content: Content) {
        handler.removeCallbacks(tick)
        val from = content.ticksFrom ?: return
        val ms = Math.floorMod(from - System.currentTimeMillis(), 1000L)
        handler.postDelayed(tick, (if (ms == 0L) 1000L else ms) + 5)
    }

    private fun end(removeNotification: Boolean) {
        handler.removeCallbacks(tick)
        ServiceCompat.stopForeground(
            this,
            if (removeNotification) ServiceCompat.STOP_FOREGROUND_REMOVE
            else ServiceCompat.STOP_FOREGROUND_DETACH,
        )
        stopSelf()
        instance = null
    }

    companion object {
        private var instance: ClockService? = null

        fun start(context: Context) {
            instance?.let { return it.redraw() }
            try {
                ContextCompat.startForegroundService(
                    context, Intent(context, ClockService::class.java)
                )
            } catch (e: IllegalStateException) {
                // Android 12+ refuses to start it from the background: show it standing still.
                ClockNotification.load(context)?.let { ClockNotification.notify(context, it) }
            }
        }

        /** Hands the notification over to a plain one (the live style). */
        fun detach() = instance?.end(removeNotification = false)

        fun stop() = instance?.end(removeNotification = true)
    }
}
