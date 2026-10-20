package id.my.anomali99.fintale

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "id.my.anomali99.fintale/import"
    private var pendingBytes: ByteArray? = null
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        )

        // Check if the activity was started with an intent containing a file
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        if (intent.action == Intent.ACTION_VIEW) {
            val uri: Uri? = intent.data
            if (uri != null) {
                try {
                    val bytes = contentResolver.openInputStream(uri)?.use {
                        it.readBytes()
                    }
                    if (bytes != null && bytes.isNotEmpty()) {
                        pendingBytes = bytes
                        // Try to send immediately if channel is ready
                        sendPendingBytes()
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    private fun sendPendingBytes() {
        val bytes = pendingBytes ?: return
        methodChannel?.invokeMethod("importFile", bytes)
        pendingBytes = null
    }
}
