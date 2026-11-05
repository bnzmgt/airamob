import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Downloads/saves a byte stream to the device's storage.
/// Returns the absolute path of the saved file, or null if failed.
Future<String?> downloadFile(List<int> bytes, String filename) async {
  try {
    Directory? targetDir;

    if (Platform.isAndroid) {
      // 1. Try public Download folder on Android (/storage/emulated/0/Download)
      // This is the ideal location where users can find files directly in their Downloads app.
      final publicDownload = Directory('/storage/emulated/0/Download');
      if (publicDownload.existsSync()) {
        try {
          final probe = File('${publicDownload.path}/.ainara_probe');
          probe.writeAsStringSync('ok');
          probe.deleteSync();
          targetDir = publicDownload;
        } catch (_) {
          // If restricted by Android Scoped Storage without SAF, fallback below
        }
      }
    }

    // 2. Try getDownloadsDirectory() provided by path_provider
    if (targetDir == null) {
      try {
        targetDir = await getDownloadsDirectory();
      } catch (_) {}
    }

    // 3. Try app external downloads directory on Android
    if (targetDir == null && Platform.isAndroid) {
      try {
        final extDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
        if (extDirs != null && extDirs.isNotEmpty) {
          targetDir = extDirs.first;
        }
      } catch (_) {}
    }

    // 4. Try app external storage directory
    if (targetDir == null && Platform.isAndroid) {
      try {
        targetDir = await getExternalStorageDirectory();
      } catch (_) {}
    }

    // 5. Fallback to application documents directory
    targetDir ??= await getApplicationDocumentsDirectory();

    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final file = File('${targetDir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  } catch (e) {
    return null;
  }
}
