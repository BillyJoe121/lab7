-- Wall of posts with likes (Lab 6 schema)

-- The wall shows the author of every post and each person edits their own profile.
create policy "profiles: leer con sesión"
on public.profiles for select to authenticated
using (true);

create policy "profiles: actualizar el propio"
on public.profiles for update to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()));

create table public.posts (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  content text not null default '' check (char_length(content) <= 280),
  created_at timestamptz not null default now()
);

create index posts_created_at_idx on public.posts (created_at desc);
create index posts_profile_id_idx on public.posts (profile_id);

create table public.likes (
  post_id uuid not null references public.posts(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, profile_id)
);

create index likes_profile_id_idx on public.likes (profile_id);

grant select, insert, delete on public.posts to authenticated;
grant select, insert, update, delete on public.likes to authenticated;

alter table public.posts enable row level security;
alter table public.likes enable row level security;

create policy "posts: leer con sesión"
on public.posts for select to authenticated
using (true);

create policy "posts: publicar los propios"
on public.posts for insert to authenticated
with check (profile_id = (select auth.uid()));

create policy "posts: borrar los propios"
on public.posts for delete to authenticated
using (profile_id = (select auth.uid()));

create policy "likes: leer con sesión"
on public.likes for select to authenticated
using (true);

create policy "likes: dar like propio"
on public.likes for insert to authenticated
with check (profile_id = (select auth.uid()));

create policy "likes: actualizar like propio"
on public.likes for update to authenticated
using (profile_id = (select auth.uid()))
with check (profile_id = (select auth.uid()));

create policy "likes: quitar like propio"
on public.likes for delete to authenticated
using (profile_id = (select auth.uid()));
