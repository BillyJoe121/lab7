import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/components/avatar.dart';
import 'package:moviles_auth/components/photo_source_sheet.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/avatar/domain/entities/photo_source.dart';
import 'package:moviles_auth/features/avatar/domain/entities/picked_photo.dart';
import 'package:moviles_auth/features/compose/ui/bloc/compose_bloc.dart';
import 'package:moviles_auth/features/compose/ui/bloc/compose_event.dart';
import 'package:moviles_auth/features/compose/ui/bloc/compose_state.dart';
import 'package:moviles_auth/features/compose/ui/screens/compose_screen.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_bloc.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_event.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_state.dart';
import 'package:moviles_auth/features/home/ui/pages/feed_page.dart';
import 'package:moviles_auth/features/home/ui/screens/home_screen.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/features/posts/domain/repository/post_repository.dart';
import 'package:moviles_auth/features/posts/domain/usecases/sign_post_images.dart';

class _FakeFeedBloc extends Bloc<FeedEvent, FeedState> implements FeedBloc {
  _FakeFeedBloc() : super(const FeedState()) {
    on<ProfileRequested>(
      (event, emit) => emit(state.copyWith(profile: _profile)),
    );
    on<FeedStarted>((event, emit) {});
    on<AvatarChangeRequested>(
      (event, emit) => emit(
        state.copyWith(
          avatarStatus: AvatarStatus.failure,
          errorMessage: 'La foto pesa más de 2 MB',
        ),
      ),
    );
    on<SignOutRequested>(
      (event, emit) => emit(state.copyWith(signedOut: true)),
    );
  }
}

class _FakeComposeBloc extends Bloc<ComposeEvent, ComposeState>
    implements ComposeBloc {
  _FakeComposeBloc() : super(const ComposeState()) {
    on<ComposeSubmitted>((event, emit) {});
    on<ComposePhotoRequested>(
      (event, emit) => emit(state.copyWith(photo: _photo)),
    );
    on<ComposePhotoRemoved>(
      (event, emit) => emit(state.copyWith(removePhoto: true)),
    );
  }
}

final _photo = PickedPhoto(
  bytes: Uint8List.fromList(const [
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0xF8,
    0xCF,
    0xC0,
    0xF0,
    0x1F,
    0x00,
    0x05,
    0x00,
    0x01,
    0xFF,
    0x89,
    0x99,
    0x3D,
    0x1D,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]),
  extension: 'png',
);

class _EventRecorder extends BlocObserver {
  final events = <Object?>[];

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    events.add(event);
  }
}

Post _post(
  String id, {
  int likes = 0,
  bool mine = false,
  bool own = false,
  String? imagePath,
}) => Post(
  id: id,
  content: 'Contenido de $id',
  createdAt: DateTime(2026, 10, 18, 10, 5),
  authorUsername: 'ana.dev',
  authorName: 'Ana Gómez',
  imagePath: imagePath,
  likeCount: likes,
  likedByMe: mine,
  isMine: own,
);

class _FakePostRepository implements PostRepository {
  final List<List<String>> signRequests = [];

  @override
  Future<Map<String, String>> imageUrls(List<String> paths) async {
    signRequests.add(paths);
    return {for (final path in paths) path: 'https://signed/$path'};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _profile = Profile(id: 'u1', username: 'ana.dev', fullName: 'Ana Gómez');

void main() {
  test('Post.copyWith only changes the likes', () {
    final liked = _post('p1', likes: 2).copyWith(likeCount: 3, likedByMe: true);
    expect(liked.likeCount, 3);
    expect(liked.likedByMe, isTrue);
    expect(liked.content, 'Contenido de p1');
  });

  test('Post.copyWith keeps the photo of the author', () {
    final post = Post(
      id: 'p1',
      content: 'Hola',
      createdAt: DateTime(2026, 10, 26),
      authorUsername: 'ana.dev',
      authorName: 'Ana Gómez',
      authorAvatarUrl: 'https://x.supabase.co/a.jpg',
      likeCount: 0,
      likedByMe: false,
    );
    expect(post.copyWith(likeCount: 1).authorAvatarUrl, post.authorAvatarUrl);
  });

  testWidgets('Avatar shows the initial while there is no photo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Avatar(url: null, name: 'ana')),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  test('ComposeState.copyWith keeps the photo until it is removed', () {
    final withPhoto = const ComposeState().copyWith(photo: _photo);
    final loading = withPhoto.copyWith(status: ComposeStatus.loading);
    expect(loading.photo, same(_photo));
    expect(loading.copyWith(removePhoto: true).photo, isNull);
  });

  test('FeedState.copyWith keeps what it is not told to change', () {
    final state = const FeedState().copyWith(posts: [_post('p1')], page: 1);
    final loading = state.copyWith(status: FeedStatus.loading);
    expect(loading.avatarStatus, AvatarStatus.idle);
    expect(loading.posts, hasLength(1));
    expect(loading.page, 1);
    expect(loading.hasMore, isTrue);
  });

  testWidgets('FeedPage shows the posts and reports likes and more', (
    tester,
  ) async {
    Post? liked;
    var more = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedPage(
            posts: [_post('p1'), _post('p2', likes: 4, mine: true)],
            hasMore: true,
            isLoading: false,
            onLoadMore: () => more++,
            onLike: (post) => liked = post,
            onDelete: (post) {},
          ),
        ),
      ),
    );
    expect(find.text('Contenido de p2'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_border));
    expect(liked?.id, 'p1');
    await tester.tap(find.text('Mostrar más'));
    expect(more, 1);
  });

  testWidgets('PostCard offers deleting only on posts of the user', (
    tester,
  ) async {
    Post? deleted;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedPage(
            posts: [_post('p1'), _post('p2', own: true)],
            hasMore: false,
            isLoading: false,
            onLoadMore: () {},
            onLike: (post) {},
            onDelete: (post) => deleted = post,
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline));
    expect(deleted?.id, 'p2');
  });

  test('signPostImages signs every image of the page in one request', () async {
    final repository = _FakePostRepository();
    final page = [
      _post('p1', imagePath: 'u1/a.jpg'),
      _post('p2'),
      _post('p3', imagePath: 'u1/b.png'),
    ];
    final signed = await signPostImages(repository, page);
    expect(repository.signRequests, [
      ['u1/a.jpg', 'u1/b.png'],
    ]);
    expect(signed[0].imageUrl, 'https://signed/u1/a.jpg');
    expect(signed[1].imageUrl, isNull);
    expect(signed[2].imageUrl, 'https://signed/u1/b.png');
  });

  test('signPostImages skips the request when no post has an image', () async {
    final repository = _FakePostRepository();
    await signPostImages(repository, [_post('p1')]);
    expect(repository.signRequests, isEmpty);
  });

  testWidgets('The photo sheet returns the chosen source', (tester) async {
    PhotoSource? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => chosen = await showPhotoSourceSheet(context),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Elegir de la galería'), findsOneWidget);
    await tester.tap(find.text('Tomar una foto'));
    await tester.pumpAndSettle();
    expect(chosen, PhotoSource.camera);
  });

  testWidgets('HomeScreen sends events to FeedBloc and switches pages', (
    tester,
  ) async {
    final recorder = _EventRecorder();
    Bloc.observer = recorder;
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (_) => BlocProvider<FeedBloc>(
            create: (_) => _FakeFeedBloc(),
            child: const HomeScreen(),
          ),
          '/login': (_) => const Scaffold(body: Text('login')),
        },
      ),
    );
    await tester.pump();
    expect(recorder.events, [isA<ProfileRequested>(), isA<FeedStarted>()]);
    expect(find.text('Todavía no hay posts'), findsOneWidget);

    await tester.tap(find.text('Perfil').last);
    await tester.pump();
    expect(find.text('@ana.dev'), findsOneWidget);
    expect(find.text('Aún no has publicado'), findsOneWidget);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('login'), findsOneWidget);
  });

  testWidgets('ComposeScreen counts characters and sends the text', (
    tester,
  ) async {
    final recorder = _EventRecorder();
    Bloc.observer = recorder;
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ComposeBloc>(
          create: (_) => _FakeComposeBloc(),
          child: const ComposeScreen(),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Hola muro');
    await tester.pump();
    expect(find.text('9/280'), findsOneWidget);
    await tester.tap(find.text('Publicar'));
    await tester.pump();
    final event = recorder.events.single as ComposeSubmitted;
    expect(event.content, 'Hola muro');
  });
}
