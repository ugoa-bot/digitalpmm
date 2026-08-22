-- ============================================================
-- Digital Project Management Blog CMS — Supabase Setup
-- Run this once in your Supabase project's SQL Editor:
-- Project → SQL Editor → New Query → paste this whole file → Run
-- ============================================================

-- 1. POSTS TABLE
create table if not exists posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text unique,
  excerpt text,
  content text not null,
  image_url text,
  category text,
  published boolean not null default false,
  scheduled_at timestamptz,        -- if set, post is hidden until this time
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Auto-update updated_at on every edit
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_posts_updated_at on posts;
create trigger trg_posts_updated_at
before update on posts
for each row execute function set_updated_at();

-- 2. ROW LEVEL SECURITY
alter table posts enable row level security;

-- Public (anon key) can only READ posts that are published AND
-- (not scheduled, or scheduled time has already passed)
drop policy if exists "Public can read published posts" on posts;
create policy "Public can read published posts"
on posts for select
to anon
using (
  published = true
  and (scheduled_at is null or scheduled_at <= now())
);

-- Only authenticated users (you, logged into the admin panel) can
-- create, edit, or delete posts
drop policy if exists "Authenticated can manage posts" on posts;
create policy "Authenticated can manage posts"
on posts for all
to authenticated
using (true)
with check (true);

-- 3. STORAGE BUCKET FOR BLOG IMAGES
insert into storage.buckets (id, name, public)
values ('blog-images', 'blog-images', true)
on conflict (id) do nothing;

-- Anyone can view images (public bucket)
drop policy if exists "Public can view blog images" on storage.objects;
create policy "Public can view blog images"
on storage.objects for select
to anon
using (bucket_id = 'blog-images');

-- Only authenticated users can upload/delete blog images
drop policy if exists "Authenticated can upload blog images" on storage.objects;
create policy "Authenticated can upload blog images"
on storage.objects for insert
to authenticated
with check (bucket_id = 'blog-images');

drop policy if exists "Authenticated can delete blog images" on storage.objects;
create policy "Authenticated can delete blog images"
on storage.objects for delete
to authenticated
using (bucket_id = 'blog-images');

-- ============================================================
-- After running this:
-- 1. Go to Authentication → Users in Supabase and create yourself
--    a login (email + password) — that's what you'll use to log
--    into admin.html.
-- 2. You're ready to publish from admin.html.
-- ============================================================
