package com.example.narco

import android.nfc.cardemulation.HostApduService
import android.os.Bundle

/**
 * Service HCE (Host Card Emulation) : l'appareil émetteur se comporte comme une
 * carte NFC. Le jeton à transmettre (octets NDEF) est fourni depuis Flutter via
 * [MainActivity] et stocké dans le compagnon statique.
 *
 * Protocole APDU (côté carte) :
 *  - SELECT AID            -> [longueurHi, longueurLo, 0x90, 0x00]
 *  - READ BINARY (00 B0)   -> [bloc d'octets, 0x90, 0x00]
 */
class NarcoHostApduService : HostApduService() {

    companion object {
        /** Octets NDEF à servir au lecteur (null = rien à émettre). */
        @Volatile
        var payload: ByteArray? = null

        /** Notifie la progression (octets servis, total). */
        @Volatile
        var onProgress: ((Int, Int) -> Unit)? = null

        /** Notifie que la totalité des octets a été lue par le lecteur. */
        @Volatile
        var onCompleted: (() -> Unit)? = null

        private val SW_OK = byteArrayOf(0x90.toByte(), 0x00)
        private val SW_NOT_FOUND = byteArrayOf(0x6A, 0x82.toByte())
        private val SW_WRONG_P1P2 = byteArrayOf(0x6B, 0x00)
        private val SW_INS_NOT_SUPPORTED = byteArrayOf(0x6D, 0x00)

        fun reset() {
            payload = null
            onProgress = null
            onCompleted = null
        }
    }

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        val apdu = commandApdu ?: return SW_INS_NOT_SUPPORTED
        val data = payload

        // SELECT AID : 00 A4 04 00 ...
        if (isSelectApdu(apdu)) {
            if (data == null) return SW_NOT_FOUND
            val len = data.size
            return byteArrayOf((len shr 8).toByte(), (len and 0xFF).toByte()) + SW_OK
        }

        // READ BINARY : 00 B0 offsetHi offsetLo Le
        if (apdu.size >= 5 && (apdu[0].toInt() and 0xFF) == 0x00 && (apdu[1].toInt() and 0xFF) == 0xB0) {
            val d = data ?: return SW_NOT_FOUND
            val offset = ((apdu[2].toInt() and 0xFF) shl 8) or (apdu[3].toInt() and 0xFF)
            var le = apdu[4].toInt() and 0xFF
            if (le == 0) le = 256
            if (offset > d.size) return SW_WRONG_P1P2

            val end = minOf(offset + le, d.size)
            val slice = d.copyOfRange(offset, end)
            onProgress?.invoke(end, d.size)
            if (end >= d.size) onCompleted?.invoke()
            return slice + SW_OK
        }

        return SW_INS_NOT_SUPPORTED
    }

    override fun onDeactivated(reason: Int) {
        // Lien NFC perdu / désélectionné : rien de spécial, l'état est piloté par Flutter.
    }

    private fun isSelectApdu(apdu: ByteArray): Boolean {
        return apdu.size >= 4 &&
            (apdu[0].toInt() and 0xFF) == 0x00 &&
            (apdu[1].toInt() and 0xFF) == 0xA4 &&
            (apdu[2].toInt() and 0xFF) == 0x04 &&
            (apdu[3].toInt() and 0xFF) == 0x00
    }
}
