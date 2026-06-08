package com.example.narco

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothServerSocket
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.InputStream
import java.io.OutputStream
import java.util.UUID

/**
 * Pont Bluetooth classique (RFCOMM / SPP) :
 *  - MethodChannel `narco/bt`        : isEnabled, bondedDevices, startDiscovery,
 *    stopDiscovery, connectAndSend, startServer, stopServer
 *  - EventChannel  `narco/bt_events` : appareils découverts + jeton reçu
 *
 * Protocole applicatif : [4 octets big-endian = longueur] + [payload JSON],
 * puis le récepteur renvoie un octet d'accusé de réception (ACK = 0x06).
 */
@SuppressLint("MissingPermission")
class BluetoothChannelHandler(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        private val SPP_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
        private const val ACK: Int = 0x06
        private const val NAK: Int = 0x15
        private const val SERVICE_NAME = "NarcoToken"
    }

    private val adapter: BluetoothAdapter? =
        (context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter

    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null

    private var serverSocket: BluetoothServerSocket? = null
    private var serverThread: Thread? = null

    private var pendingSocket: BluetoothSocket? = null
    private var pendingOutputStream: OutputStream? = null

    private var discoveryReceiver: BroadcastReceiver? = null

    init {
        MethodChannel(messenger, "narco/bt").setMethodCallHandler(this)
        EventChannel(messenger, "narco/bt_events").setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isEnabled" -> result.success(adapter?.isEnabled == true)
            "bondedDevices" -> {
                val devices = adapter?.bondedDevices?.map {
                    mapOf("name" to (it.name ?: "?"), "address" to it.address)
                } ?: emptyList()
                result.success(devices)
            }
            "startDiscovery" -> {
                startDiscovery()
                result.success(true)
            }
            "stopDiscovery" -> {
                stopDiscovery()
                result.success(true)
            }
            "connectAndSend" -> {
                val address = call.argument<String>("address")
                val payload = call.argument<ByteArray>("payload")
                if (address == null || payload == null) {
                    result.error("BAD_ARGS", "Adresse ou payload manquant.", null)
                } else {
                    connectAndSend(address, payload, result)
                }
            }
            "startServer" -> {
                startServer()
                result.success(true)
            }
            "stopServer" -> {
                stopServer()
                result.success(true)
            }
            "respondToTransfer" -> {
                val accept = call.argument<Boolean>("accept") ?: false
                respondToTransfer(accept, result)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun emit(data: Map<String, Any?>) {
        mainHandler.post { eventSink?.success(data) }
    }

    // -------------------------------------------------------------------------
    // Émission (client)
    // -------------------------------------------------------------------------

    private fun connectAndSend(address: String, payload: ByteArray, result: MethodChannel.Result) {
        Thread {
            var socket: BluetoothSocket? = null
            val timeoutRunnable = Runnable {
                try {
                    socket?.close()
                } catch (_: Exception) {}
            }
            try {
                adapter?.cancelDiscovery()
                val device: BluetoothDevice = adapter!!.getRemoteDevice(address)
                socket = device.createRfcommSocketToServiceRecord(SPP_UUID)
                
                // Programmation du timeout de connexion (6 secondes)
                mainHandler.postDelayed(timeoutRunnable, 6000L)
                
                socket.connect()
                
                // Connexion réussie, on annule le timeout
                mainHandler.removeCallbacks(timeoutRunnable)

                val out: OutputStream = socket.outputStream
                val input: InputStream = socket.inputStream

                val len = payload.size
                val header = byteArrayOf(
                    (len ushr 24).toByte(),
                    (len ushr 16).toByte(),
                    (len ushr 8).toByte(),
                    len.toByte(),
                )
                out.write(header)
                out.write(payload)
                out.flush()

                val ack = input.read()
                socket.close()

                mainHandler.post {
                    when (ack) {
                        ACK -> result.success(true)
                        NAK -> result.error("REJECTED", "Transfert refusé par le récepteur.", null)
                        else -> result.error("NO_ACK", "Accusé de réception invalide.", null)
                    }
                }
            } catch (e: Exception) {
                mainHandler.removeCallbacks(timeoutRunnable)
                try { socket?.close() } catch (_: Exception) {}
                mainHandler.post { result.error("BT_SEND", e.message ?: "Échec de l'envoi.", null) }
            }
        }.start()
    }

    // -------------------------------------------------------------------------
    // Réception (serveur)
    // -------------------------------------------------------------------------

    private fun startServer() {
        stopServer()
        try {
            serverSocket = adapter?.listenUsingRfcommWithServiceRecord(SERVICE_NAME, SPP_UUID)
        } catch (e: Exception) {
            emit(mapOf("event" to "error", "message" to (e.message ?: "Serveur indisponible.")))
            return
        }

        serverThread = Thread {
            try {
                pendingSocket = serverSocket?.accept()
                pendingSocket?.let { socket ->
                    val input: InputStream = socket.inputStream
                    pendingOutputStream = socket.outputStream

                    val header = readFully(input, 4)
                    val length = ((header[0].toInt() and 0xFF) shl 24) or
                        ((header[1].toInt() and 0xFF) shl 16) or
                        ((header[2].toInt() and 0xFF) shl 8) or
                        (header[3].toInt() and 0xFF)

                    val payload = readFully(input, length)

                    emit(mapOf("event" to "received", "payload" to payload))
                }
            } catch (e: Exception) {
                try { pendingSocket?.close() } catch (_: Exception) {}
                pendingSocket = null
                pendingOutputStream = null
                if (serverSocket != null) {
                    emit(mapOf("event" to "error", "message" to (e.message ?: "Réception interrompue.")))
                }
            }
        }
        serverThread?.start()
    }

    private fun stopServer() {
        try { serverSocket?.close() } catch (_: Exception) {}
        serverSocket = null
        serverThread?.interrupt()
        serverThread = null
    }

    private fun readFully(input: InputStream, length: Int): ByteArray {
        val buffer = ByteArray(length)
        var read = 0
        while (read < length) {
            val count = input.read(buffer, read, length - read)
            if (count == -1) throw java.io.IOException("Flux fermé avant la fin des données.")
            read += count
        }
        return buffer
    }

    // -------------------------------------------------------------------------
    // Découverte
    // -------------------------------------------------------------------------

    private fun startDiscovery() {
        stopDiscovery()
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context?, intent: Intent?) {
                if (intent?.action == BluetoothDevice.ACTION_FOUND) {
                    val device: BluetoothDevice? =
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    if (device != null) {
                        emit(
                            mapOf(
                                "event" to "discovered",
                                "name" to (device.name ?: "?"),
                                "address" to device.address,
                            )
                        )
                    }
                }
            }
        }
        discoveryReceiver = receiver
        val filter = IntentFilter(BluetoothDevice.ACTION_FOUND)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(receiver, filter)
        }
        adapter?.startDiscovery()
    }

    private fun stopDiscovery() {
        try { adapter?.cancelDiscovery() } catch (_: Exception) {}
        discoveryReceiver?.let {
            try { context.unregisterReceiver(it) } catch (_: Exception) {}
        }
        discoveryReceiver = null
    }

    private fun respondToTransfer(accept: Boolean, result: MethodChannel.Result) {
        try {
            val out = pendingOutputStream
            if (out == null) {
                result.error("NO_PENDING", "Aucun transfert en attente.", null)
                return
            }
            out.write(if (accept) ACK else NAK)
            out.flush()
            pendingSocket?.close()
            result.success(true)
        } catch (e: Exception) {
            result.error("RESPOND_FAILED", e.message, null)
        } finally {
            pendingSocket = null
            pendingOutputStream = null
        }
    }

    fun cleanup() {
        stopServer()
        stopDiscovery()
    }
}
