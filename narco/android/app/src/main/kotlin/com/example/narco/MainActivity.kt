package com.example.narco

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Ponts Flutter ↔ natif pour le HCE NFC :
 *  - MethodChannel `narco/hce`        : startEmulation(payload) / stopEmulation
 *  - EventChannel  `narco/hce_events` : progression et fin de transmission
 */
class MainActivity : FlutterActivity() {

    private val methodChannelName = "narco/hce"
    private val eventChannelName = "narco/hce_events"

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, methodChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "startEmulation" -> {
                    val payload = call.argument<ByteArray>("payload")
                    if (payload == null) {
                        result.error("NO_PAYLOAD", "Aucun jeton à émettre.", null)
                        return@setMethodCallHandler
                    }
                    NarcoHostApduService.payload = payload
                    NarcoHostApduService.onProgress = { served, total ->
                        mainHandler.post {
                            eventSink?.success(
                                mapOf("event" to "progress", "served" to served, "total" to total)
                            )
                        }
                    }
                    NarcoHostApduService.onCompleted = {
                        mainHandler.post {
                            eventSink?.success(mapOf("event" to "completed"))
                        }
                    }
                    result.success(true)
                }
                "stopEmulation" -> {
                    NarcoHostApduService.reset()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, eventChannelName).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }
}
