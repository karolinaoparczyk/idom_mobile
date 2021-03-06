package com.project.idom

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import io.flutter.plugin.common.MethodChannel
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.net.Uri;
import android.media.AudioAttributes;
import android.content.ContentResolver;
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions

class MainActivity : FlutterActivity() {
    private val CHANNEL = "flutter.idom/notifications"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            if (call.method == "createNotificationChannel") {
                val argData = call.arguments as java.util.HashMap<String, String>
                val completed = createNotificationChannel(argData)
                if (completed == true) {
                    result.success(completed)
                    try {
                        val app = FirebaseApp.getInstance();
                        app.delete();

                    } catch (e: IllegalStateException) {

                    }
                    val builder: FirebaseOptions.Builder = FirebaseOptions.Builder()
                            .setApplicationId(argData["mobileAppId"].toString())
                            .setApiKey(argData["apiKey"].toString())
                            .setDatabaseUrl(argData["firebaseUrl"].toString())
                            .setStorageBucket(argData["storageBucket"].toString())
                    FirebaseApp.initializeApp(this, builder.build());

                } else {
                    result.error("Error Code", "Error Message", null)
                }
            } else {
                result.notImplemented()
            }
        }

    }

    private fun createNotificationChannel(mapData: HashMap<String, String>): Boolean {
        val completed: Boolean
        if (VERSION.SDK_INT >= VERSION_CODES.O) {
            val id = mapData["id"]
            val name = mapData["name"]
            val descriptionText = mapData["description"]
            val importance = NotificationManager.IMPORTANCE_HIGH
            val mChannel = NotificationChannel(id, name, importance)
            mChannel.description = descriptionText
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(mChannel)
            completed = true
        } else {
            completed = false
        }
        return completed
    }
}