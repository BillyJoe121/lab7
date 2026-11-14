import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/features/posts/domain/repository/post_repository.dart';

/// Completes every post that has an image with its URL, asking for all of them at once.
Future<List<Post>> signPostImages(PostRepository posts, List<Post> page) async {
  final paths = {
    for (final post in page)
      if (post.imagePath != null) post.imagePath!,
  }.toList();
  if (paths.isEmpty) return page;
  final urls = await posts.imageUrls(paths);
  return [
    for (final post in page)
      post.imagePath == null
          ? post
          : post.copyWith(imageUrl: urls[post.imagePath]),
  ];
}
