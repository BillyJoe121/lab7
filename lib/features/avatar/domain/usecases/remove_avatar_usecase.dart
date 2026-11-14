import 'package:moviles_auth/features/auth/data/repository/auth_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/repository/profile_repository_impl.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/features/avatar/data/repository/avatar_repository_impl.dart';
import 'package:moviles_auth/features/avatar/domain/repository/avatar_repository.dart';

/// Leaves the profile without photo and deletes the file from Storage.
class RemoveAvatarUseCase {
  final AuthRepository _auth = AuthRepositoryImpl();
  final ProfileRepository _profiles = ProfileRepositoryImpl();
  final AvatarRepository _avatars = AvatarRepositoryImpl();

  Future<Profile> call() async {
    final user = _auth.currentUser();
    if (user == null) throw Exception('No hay una sesión iniciada');
    final before = await _profiles.getProfile(user.id);
    final oldPath = before.avatarPath;
    if (oldPath == null) return before;
    await _profiles.updateAvatarPath(user.id, null);
    await _avatars.remove(oldPath);
    return _profiles.getProfile(user.id);
  }
}
