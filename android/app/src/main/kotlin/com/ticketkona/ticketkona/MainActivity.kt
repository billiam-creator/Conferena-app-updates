package com.ticketkona.ticketkona

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "conferena/intent"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "open") {
                val action = call.argument<String>("action")
                val data = call.argument<String>("data")

                try {
                    val intent = when (action) {
                        "tel" -> Intent(Intent.ACTION_DIAL, Uri.parse("tel:$data"))
                        "mailto" -> Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:$data"))
                        "view" -> Intent(Intent.ACTION_VIEW, Uri.parse(data))
                        else -> null
                    }

                    if (intent != null) {
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.error("UNSUPPORTED", "Unsupported action: $action", null)
                    }
                } catch (e: Exception) {
                    result.error("LAUNCH_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
