-- Add scheduling support for blog posts.
-- Run this once in Supabase SQL Editor.

alter table public.posts
add column if not exists publish_at timestamptz null;

-- Replace the public policy so scheduled posts are not visible before their time.
drop policy if exists "Public can read published posts" on public.posts;

create policy "Public can read published posts"
on public.posts
for select
using (
  published = true
  and (publish_at is null or publish_at <= now())
);

-- Authenticated admins can still see and manage all posts.
drop policy if exists "Authenticated users manage posts" on public.posts;

create policy "Authenticated users manage posts"
on public.posts
for all
to authenticated
using (true)
with check (true);
