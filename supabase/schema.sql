-- Vhalor RPG — Supabase foundation
-- Run this in Supabase Dashboard > SQL Editor after creating the project.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  display_name text,
  role text not null default 'player' check (role in ('player','admin')),
  approval_status text not null default 'pending' check (approval_status in ('pending','approved','rejected','blocked')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.characters (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null default 'Personagem sem nome',
  sheet jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.game_systems (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  content jsonb not null default '{}'::jsonb,
  updated_by uuid references public.profiles(id),
  updated_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

create or replace function public.is_approved()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and approval_status = 'approved'
  );
$$;

create or replace function public.create_profile_for_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name, role, approval_status)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data->>'display_name', ''),
    'player',
    'pending'
  )
  on conflict (id) do update
    set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_vhalor on auth.users;
create trigger on_auth_user_created_vhalor
after insert on auth.users
for each row execute procedure public.create_profile_for_new_user();

create or replace function public.sync_profile_email()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles set email = coalesce(new.email, ''), updated_at = now()
  where id = new.id;
  return new;
end;
$$;

drop trigger if exists on_auth_user_email_updated_vhalor on auth.users;
create trigger on_auth_user_email_updated_vhalor
after update of email on auth.users
for each row execute procedure public.sync_profile_email();

alter table public.profiles enable row level security;
alter table public.characters enable row level security;
alter table public.game_systems enable row level security;

-- Users can see their own profile. Admins can see all profiles, including emails.
drop policy if exists "profile read self or admin" on public.profiles;
create policy "profile read self or admin" on public.profiles
for select to authenticated
using (id = auth.uid() or public.is_admin());

-- Only admins can update roles, approvals, blocks or profile data.
drop policy if exists "profile update admin only" on public.profiles;
create policy "profile update admin only" on public.profiles
for update to authenticated
using (public.is_admin())
with check (public.is_admin());

-- Approved players can access their own character sheets; admins can access all.
drop policy if exists "character read approved owner or admin" on public.characters;
create policy "character read approved owner or admin" on public.characters
for select to authenticated
using (public.is_admin() or (public.is_approved() and owner_id = auth.uid()));

drop policy if exists "character create approved owner" on public.characters;
create policy "character create approved owner" on public.characters
for insert to authenticated
with check (public.is_approved() and owner_id = auth.uid());

drop policy if exists "character update owner or admin" on public.characters;
create policy "character update owner or admin" on public.characters
for update to authenticated
using (public.is_admin() or (public.is_approved() and owner_id = auth.uid()))
with check (public.is_admin() or (public.is_approved() and owner_id = auth.uid()));

drop policy if exists "character delete owner or admin" on public.characters;
create policy "character delete owner or admin" on public.characters
for delete to authenticated
using (public.is_admin() or (public.is_approved() and owner_id = auth.uid()));

-- Approved players can read the RPG system. Only admins can edit it.
drop policy if exists "system read approved or admin" on public.game_systems;
create policy "system read approved or admin" on public.game_systems
for select to authenticated
using (public.is_admin() or public.is_approved());

drop policy if exists "system insert admin only" on public.game_systems;
create policy "system insert admin only" on public.game_systems
for insert to authenticated
with check (public.is_admin());

drop policy if exists "system update admin only" on public.game_systems;
create policy "system update admin only" on public.game_systems
for update to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "system delete admin only" on public.game_systems;
create policy "system delete admin only" on public.game_systems
for delete to authenticated
using (public.is_admin());

-- ONE-TIME ADMIN SETUP:
-- 1) Create/sign up the administrator account using the chosen email.
-- 2) Run the statement below once in the SQL Editor, replacing the email if needed.
-- Do not expose a service_role key in frontend code.
-- update public.profiles set role = 'admin', approval_status = 'approved'
-- where lower(email) = lower('Mestrelegalbacanamaneiro@gmail.com');
