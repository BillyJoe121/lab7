import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviles_auth/components/photo_source_sheet.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_bloc.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_event.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_state.dart';
import 'package:moviles_auth/features/home/ui/pages/feed_page.dart';
import 'package:moviles_auth/features/home/ui/pages/profile_page.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';

/// Hosts FeedPage and ProfilePage behind a BottomNavigationBar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<FeedBloc>();
    bloc.add(ProfileRequested());
    bloc.add(FeedStarted());
  }

  Future<void> _openCompose() async {
    final published = await Navigator.pushNamed(context, '/compose');
    if (published == true && mounted) {
      context.read<FeedBloc>().add(FeedStarted());
    }
  }

  Widget _page(FeedState state) {
    final bloc = context.read<FeedBloc>();
    if (_index == 1) {
      final profile = state.profile;
      if (profile == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return ProfilePage(
        profile: profile,
        posts: state.myPosts,
        isUploading: state.avatarStatus == AvatarStatus.uploading,
        onChangePhoto: () => _choosePhoto(),
        onRemovePhoto: () => bloc.add(AvatarRemoveRequested()),
        onLike: (post) => bloc.add(FeedLikeToggled(post)),
        onDelete: (post) => _confirmDelete(post),
        onSignOut: () => bloc.add(SignOutRequested()),
      );
    }
    return FeedPage(
      posts: state.posts,
      hasMore: state.hasMore,
      isLoading: state.status == FeedStatus.loading,
      onLoadMore: () => bloc.add(FeedMoreRequested()),
      onLike: (post) => bloc.add(FeedLikeToggled(post)),
      onDelete: (post) => _confirmDelete(post),
    );
  }

  Future<void> _choosePhoto() async {
    final source = await showPhotoSourceSheet(context);
    if (source == null || !mounted) return;
    context.read<FeedBloc>().add(AvatarChangeRequested(source));
  }

  Future<void> _confirmDelete(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar este post?'),
        content: const Text('Se borra también su imagen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.read<FeedBloc>().add(FeedPostDeleted(post));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FeedBloc, FeedState>(
          listenWhen: (previous, current) =>
              !previous.signedOut && current.signedOut,
          listener: (context, state) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
        ),
        BlocListener<FeedBloc, FeedState>(
          listenWhen: (previous, current) =>
              previous.avatarStatus != current.avatarStatus &&
              current.avatarStatus == AvatarStatus.failure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Algo falló')),
            );
          },
        ),
        BlocListener<FeedBloc, FeedState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == FeedStatus.failure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Algo falló')),
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(_index == 0 ? 'Muro' : 'Perfil')),
        body: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) => _page(state),
        ),
        floatingActionButton: _index == 0
            ? FloatingActionButton(
                onPressed: () => _openCompose(),
                child: const Icon(Icons.edit),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (index) => setState(() => _index = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Muro',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
