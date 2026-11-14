-- Anyone signed in can read both buckets; writing is limited to the user's own folder (<uid>/...).

drop policy "avatars: usuarios autenticados" on storage.objects;
drop policy "post-images: usuarios autenticados" on storage.objects;

create policy "avatars: leer con sesión"
on storage.objects for select to authenticated
using (bucket_id = 'avatars');

create policy "avatars: subir en su carpeta"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "avatars: actualizar en su carpeta"
on storage.objects for update to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "avatars: borrar en su carpeta"
on storage.objects for delete to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "post-images: leer con sesión"
on storage.objects for select to authenticated
using (bucket_id = 'post-images');

create policy "post-images: subir en su carpeta"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'post-images'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "post-images: actualizar en su carpeta"
on storage.objects for update to authenticated
using (
  bucket_id = 'post-images'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
)
with check (
  bucket_id = 'post-images'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "post-images: borrar en su carpeta"
on storage.objects for delete to authenticated
using (
  bucket_id = 'post-images'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);
