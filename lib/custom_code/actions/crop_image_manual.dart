// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Imports
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

Future<FFUploadedFile?> cropImageManual(FFUploadedFile? imageFile) async {
  // Verificações de segurança
  if (imageFile == null || imageFile.bytes == null) return null;

  try {
    // 1. CRIAR ARQUIVO TEMPORÁRIO (O Cropper precisa de arquivo físico)
    final tempDir = await getTemporaryDirectory();
    final tempPath =
        '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = await File(tempPath).create();
    await file.writeAsBytes(imageFile.bytes!);

    // 2. RECORTAR
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: tempPath,
      compressQuality: 90, // Qualidade levemente reduzida para performance
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Ajuste o Recorte',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false), // Livre para ajustar
        IOSUiSettings(
          title: 'Recortar',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (croppedFile == null) return null; // Usuário cancelou

    // 3. CONVERTER DE VOLTA PARA BYTES (Para o FlutterFlow exibir)
    final croppedBytes = await File(croppedFile.path).readAsBytes();

    return FFUploadedFile(
      bytes: croppedBytes,
      name: 'cropped_${imageFile.name}',
    );
  } catch (e) {
    print('Erro ao recortar: $e');
    return null;
  }
}
