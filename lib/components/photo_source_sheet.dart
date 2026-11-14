import 'package:flutter/material.dart';

import 'package:moviles_auth/features/avatar/domain/entities/photo_source.dart';

/// Asks where the photo comes from. Returns null if the person closes the sheet.
Future<PhotoSource?> showPhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<PhotoSource>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Elegir de la galería'),
            onTap: () => Navigator.pop(context, PhotoSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Tomar una foto'),
            onTap: () => Navigator.pop(context, PhotoSource.camera),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
