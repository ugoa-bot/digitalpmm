
-- Ugochinyere Website CMS
-- Run this in Supabase SQL Editor.

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text unique not null,
  excerpt text,
  content text not null,
  image_url text,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  content text,
  image_url text,
  published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.case_studies (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text,
  description text,
  result text,
  url text,
  image_url text,
  published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.posts enable row level security;
alter table public.services enable row level security;
alter table public.case_studies enable row level security;

create policy "Public can read published posts" on public.posts
for select using (published = true);

create policy "Public can read published services" on public.services
for select using (published = true);

create policy "Public can read published case studies" on public.case_studies
for select using (published = true);

create policy "Authenticated users manage posts" on public.posts
for all to authenticated using (true) with check (true);

create policy "Authenticated users manage services" on public.services
for all to authenticated using (true) with check (true);

create policy "Authenticated users manage case studies" on public.case_studies
for all to authenticated using (true) with check (true);

insert into storage.buckets (id, name, public)
values ('site-media','site-media',true)
on conflict (id) do nothing;

create policy "Public can view site media" on storage.objects
for select using (bucket_id = 'site-media');

create policy "Authenticated users upload site media" on storage.objects
for insert to authenticated with check (bucket_id = 'site-media');

create policy "Authenticated users update site media" on storage.objects
for update to authenticated using (bucket_id = 'site-media');

create policy "Authenticated users delete site media" on storage.objects
for delete to authenticated using (bucket_id = 'site-media');
