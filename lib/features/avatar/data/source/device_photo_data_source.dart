import 'package:image_picker/image_picker.dart';
import 'package:moviles_auth/features/avatar/domain/entities/photo_source.dart';
import 'package:moviles_auth/features/avatar/domain/entities/picked_photo.dart';

/// The only file that opens the gallery or the camera of the phone.
class DevicePhotoDataSource {
  final ImagePicker _picker = ImagePicker();

  ImageSource _toImageSource(PhotoSource source) {
    return switch (source) {
      PhotoSource.gallery => ImageSource.gallery,
      PhotoSource.camera => ImageSource.camera,
    };
  }

  Future<PickedPhoto?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: _toImageSource(source),
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (file == null) return null;
    return PickedPhoto(
      bytes: await file.readAsBytes(),
      extension: file.name.split('.').last.toLowerCase(),
    );
  }
}
