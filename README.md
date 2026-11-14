# Laboratorio 7 · Fotos en el muro

Punto de partida del **Laboratorio 7**: el muro del Laboratorio 6, ya resuelto, al que le faltan las fotos. La guía paso a paso está en el visor del curso, en la lección *Laboratorio 7 · Fotos en el muro*.

- **Parte 1 · Foto de perfil.** Subir la foto, guardar su path en `profiles` y mostrarla en el perfil y junto a cada post.
- **Parte 2 · Posts con imagen (avanzada).** El composer adjunta una foto, la muestra antes de publicar y el muro la pinta bajo el texto.

Las fotos de perfil van en un **bucket público**, `avatars`: se muestran con una URL fija. Las de los posts van en un **bucket privado**, `post-images`: solo quien inició sesión las ve, a través de URLs firmadas.

## Cómo correrlo

1. Pon la `Project URL` y la `publishable key` de **tu** proyecto de Supabase en `lib/main.dart`.
2. Conecta la carpeta con tu proyecto de Supabase, el mismo del Laboratorio 6:

```bash
npx supabase init
npx supabase link --project-ref TU_IDENTIFICADOR
npx supabase migration fetch --linked
```

   Reemplaza el `config.toml` que crea `init` por el del curso, y sigue los pasos del laboratorio para los buckets y las migraciones nuevas.
3. Corre la app:

```bash
flutter pub get
flutter run
```

## Qué ya funciona

- **Todo el Laboratorio 6.** Registro, inicio de sesión, el muro paginado, los «me gusta» y publicar texto.
- **Las dependencias y los permisos.** `image_picker` y `uuid` en el `pubspec.yaml`, los textos de permiso en `ios/Runner/Info.plist` y el permiso de archivos en los `entitlements` de macOS.
- **Toda la interfaz.** `Avatar`, el botón de cámara de `ProfilePage`, el botón *Agregar foto*, la vista previa y *Quitar foto* de `ComposeScreen`, y la imagen de `PostCard`. Los dos botones de foto todavía no lanzan su evento: `() {}`.
- **Las entidades y los contratos.** `PickedPhoto`, `Profile` con `avatarPath` y `avatarUrl`, `Post` con `authorAvatarUrl`, `imagePath` e `imageUrl`, y los contratos `AvatarRepository`, `ProfileRepository` y `PostRepository` completos.
- **Los eventos y los estados.** `AvatarChangeRequested`, `ComposePhotoRequested`, `ComposePhotoRemoved`, `FeedState.avatarStatus` y `ComposeState.photo`, con sus `copyWith`.

Los métodos nuevos de cada capa ya existen con su firma, pero su cuerpo es `throw UnimplementedError()`. Los `on` nuevos de los Bloc solo imprimen el evento que reciben. Cuando conectes los botones, verás en la consola:

```text
FeedBloc recibió AvatarChangeRequested()
ComposeBloc recibió ComposePhotoRequested()
```

## Qué te toca

**Parte 1**

- `avatar/domain/usecases/change_avatar_usecase.dart`: `call`.
- `avatar/data/source/device_photo_data_source.dart`: `pick`.
- `avatar/data/source/supabase_avatar_data_source.dart`: `upload` con nombre aleatorio y `remove`.
- `avatar/data/repository/avatar_repository_impl.dart`: los tres métodos, delegando.
- `auth/data/source/supabase_profile_data_source.dart` y su `Impl`: `updateAvatarPath`, y la URL pública en `getProfile`.
- `posts/data/source/supabase_post_data_source.dart`: `avatar_path` en el select y su URL pública en `_toPost`.
- `home/ui/bloc/feed_bloc.dart`: el `on` de `AvatarChangeRequested`.
- `home/ui/screens/home_screen.dart`: que `onChangePhoto` lance `AvatarChangeRequested`.

**Parte 2**

- `posts/domain/usecases/pick_post_image_usecase.dart`: `call`.
- `posts/domain/usecases/publish_post_usecase.dart`: subir la foto antes de crear el post.
- `posts/data/source/supabase_post_image_data_source.dart`: `upload` y `signedUrl`.
- `posts/data/repository/post_repository_impl.dart`: `pickImage`, `uploadImage` e `imageUrl`.
- `posts/data/source/supabase_post_data_source.dart`: `image_path` en `create`, en el select y en `_toPost`.
- `posts/domain/usecases/get_feed_usecase.dart` y `get_my_posts_usecase.dart`: completar cada post con la URL firmada de su imagen.
- `compose/ui/bloc/compose_bloc.dart`: los `on` de la foto, y pasar `state.photo` al publicar.
- `compose/ui/screens/compose_screen.dart`: que *Agregar foto* lance `ComposePhotoRequested`.

`flutter test` comprueba que la interfaz lanza los eventos correctos.

## Retos

1. **Cada quien escribe solo en su carpeta.** La migración `20261113130000_storage_own_folder.sql` deja leer ambos buckets con sesión, pero solo permite subir, actualizar y borrar cuando `(storage.foldername(name))[1] = (select auth.uid()::text)`. Las rutas ya empiezan por el uid (`<uid>/<uuid>.<ext>`).
2. **Galería o cámara.** `showPhotoSourceSheet` (en `lib/components/photo_source_sheet.dart`) abre un bottom sheet. El dominio usa su propio `enum PhotoSource { gallery, camera }` y solo `DevicePhotoDataSource` lo traduce a `ImageSource` de image_picker.
3. **Quitar la foto de perfil.** `RemoveAvatarUseCase` primero pone `avatar_path` en `null` y después borra el archivo, para que el perfil nunca apunte a un archivo que ya no existe.
4. **`cached_network_image`.** `Avatar` y `PostCard` lo usan en lugar de `Image.network`. *¿Ayuda con las URLs firmadas?* No por sí solo: la caché se indexa por URL y cada carga del muro firma una URL nueva (con otro `token`), así que nunca habría acierto. Por eso `PostCard` usa `cacheKey: post.imagePath`, porque la ruta es estable aunque la URL cambie. En los avatares sí ayuda directamente, porque la URL pública es fija.
5. **Borrar un post borra su imagen.** `DeletePostUseCase` solo deja borrar posts propios. Borra la fila y luego el archivo del bucket. El botón aparece solo en los posts propios y pide confirmación.
6. **Firmas en lote.** `signPostImages` junta las rutas de la página y hace una sola llamada a `createSignedUrlsResult(paths, 3600)` en lugar de una por post. Lo usan `GetFeedUseCase` y `GetMyPostsUseCase`.
