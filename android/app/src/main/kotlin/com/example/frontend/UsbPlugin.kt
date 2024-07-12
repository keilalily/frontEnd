import android.content.Context
import android.os.Environment
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class UsbPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.app/usb")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "listFiles") {
      val deviceId = call.argument<Int>("device")
      val files = listFilesFromUsb(deviceId)
      result.success(files)
    } else {
      result.notImplemented()
    }
  }

  private fun listFilesFromUsb(deviceId: Int?): List<String> {
    // Use SAF or direct access to list files
    // This is a simplified example, you might need more checks and proper handling
    val dir = DocumentFile.fromFile(Environment.getExternalStorageDirectory())
    val files = mutableListOf<String>()
    dir?.listFiles()?.forEach { file ->
      if (file.isFile && (file.name?.endsWith(".pdf") == true || file.name?.endsWith(".docx") == true || file.name?.endsWith(".pptx") == true)) {
        files.add(file.name ?: "Unknown")
      }
    }
    return files
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
