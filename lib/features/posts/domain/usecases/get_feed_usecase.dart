import 'package:moviles_auth/features/posts/data/repository/post_repository_impl.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/features/posts/domain/repository/post_repository.dart';
import 'package:moviles_auth/features/posts/domain/usecases/sign_post_images.dart';

/// Brings one page of the wall, newest first, each post with the URL of its image.
class GetFeedUseCase {
  final PostRepository _posts = PostRepositoryImpl();

  Future<List<Post>> call({required int page, required int size}) async {
    final posts = await _posts.fetchFeed(page: page, size: size);
    return signPostImages(_posts, posts);
  }
}
