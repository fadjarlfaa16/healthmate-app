import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart'; // ⬅️ Tambahkan ini di pubspec.yaml!

class ImageHelper {
  static Future<File?> compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory(); // Folder temporary app
      final targetPath =
          "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 30,
        minWidth: 600,
        minHeight: 600,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }
}
