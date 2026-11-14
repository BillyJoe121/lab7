import 'package:moviles_auth/features/posts/data/repository/post_repository_impl.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/features/posts/domain/repository/post_repository.dart';
import 'package:moviles_auth/features/posts/domain/usecases/sign_post_images.dart';

/// Brings the latest posts of the signed in user, each with the URL of its image.
class GetMyPostsUseCase {
  final PostRepository _posts = PostRepositoryImpl();

  Future<List<Post>> call({int limit = 3}) async {
    final posts = await _posts.fetchMine(limit: limit);
    return signPostImages(_posts, posts);
  }
}
