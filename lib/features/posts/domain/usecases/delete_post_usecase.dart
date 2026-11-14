import 'package:moviles_auth/features/posts/data/repository/post_repository_impl.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/features/posts/domain/repository/post_repository.dart';

/// Deletes a post of the signed in user and then its image from Storage.
class DeletePostUseCase {
  final PostRepository _posts = PostRepositoryImpl();

  Future<void> call(Post post) async {
    if (!post.isMine) throw Exception('Solo puedes borrar tus posts');
    await _posts.delete(post.id);
    final path = post.imagePath;
    if (path != null) await _posts.removeImage(path);
  }
}
