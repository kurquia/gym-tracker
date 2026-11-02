package com.kurquia.gym_tracker

import android.content.ContentUris
import android.content.ContentValues
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gym_tracker/backups")
            .setMethodCallHandler { call, result ->
                val main = Handler(Looper.getMainLooper())
                // File work off the UI thread; the result goes back on it.
                thread {
                    try {
                        val value = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            handle(call)
                        } else {
                            error("Backups need Android 10 or newer")
                        }
                        main.post { result.success(value) }
                    } catch (e: Exception) {
                        main.post { result.error("backup", e.message, null) }
                    }
                }
            }
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun handle(call: MethodCall): Any? = when (call.method) {
        "save" -> save(call.argument<String>("path")!!, call.argument<String>("name")!!)
        "names" -> names().map { it.second }
        "delete" -> delete(call.argument<String>("name")!!)
        else -> error("unknown method ${call.method}")
    }

    // Documents/Gym Tracker/ in shared storage, through MediaStore: the app
    // sees and deletes only the files it wrote, and needs no permission.
    private val folder = "Documents/Gym Tracker/"
    private val collection
        @RequiresApi(Build.VERSION_CODES.Q) get() = MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun save(path: String, name: String): Nothing? {
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, name)
            put(MediaStore.MediaColumns.MIME_TYPE, "application/octet-stream")
            put(MediaStore.MediaColumns.RELATIVE_PATH, folder)
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }
        val uri = contentResolver.insert(collection, values) ?: error("could not create $name")
        try {
            contentResolver.openOutputStream(uri)!!.use { out -> File(path).inputStream().use { it.copyTo(out) } }
        } catch (e: Exception) {
            contentResolver.delete(uri, null, null)
            throw e
        }
        contentResolver.update(uri, ContentValues().apply { put(MediaStore.MediaColumns.IS_PENDING, 0) }, null, null)
        return null
    }

    // (id, display name) of the backups the app wrote.
    @RequiresApi(Build.VERSION_CODES.Q)
    private fun names(): List<Pair<Long, String>> {
        val found = mutableListOf<Pair<Long, String>>()
        contentResolver.query(
            collection,
            arrayOf(MediaStore.MediaColumns._ID, MediaStore.MediaColumns.DISPLAY_NAME),
            "${MediaStore.MediaColumns.RELATIVE_PATH} = ?",
            arrayOf(folder),
            null,
        )?.use { c ->
            while (c.moveToNext()) found.add(c.getLong(0) to c.getString(1))
        }
        return found
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun delete(name: String): Nothing? {
        for ((id, n) in names()) {
            if (n == name) contentResolver.delete(ContentUris.withAppendedId(collection, id), null, null)
        }
        return null
    }
}
