-- ScholarTrack schema. Run in the Supabase SQL editor.

create extension if not exists pgcrypto;

-- Enums
do $$ begin
  create type public.application_status as enum
    ('saved', 'applying', 'submitted', 'awarded', 'rejected');
exception when duplicate_object then null;
end $$;

-- Shared trigger: keep updated_at fresh
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  cgpa numeric(3, 2) check (cgpa between 3.00 and 5.00),
  field_of_study text,
  level text,
  country text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Auto-create a profile row on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- scholarships
create table if not exists public.scholarships (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  provider text not null,
  description text,
  min_cgpa numeric(3, 2) not null default 3.00
    check (min_cgpa between 3.00 and 5.00),
  max_cgpa numeric(3, 2)
    check (max_cgpa is null or (max_cgpa between 3.00 and 5.00 and max_cgpa >= min_cgpa)),
  amount numeric(12, 2),
  currency text default 'USD',
  deadline date,
  level text,
  field_of_study text,
  countries text[] not null default '{}',
  apply_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists scholarships_set_updated_at on public.scholarships;
create trigger scholarships_set_updated_at
  before update on public.scholarships
  for each row execute function public.set_updated_at();

create index if not exists scholarships_min_cgpa_idx on public.scholarships (min_cgpa);
create index if not exists scholarships_deadline_idx on public.scholarships (deadline);

-- saved_scholarships
create table if not exists public.saved_scholarships (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  scholarship_id uuid not null references public.scholarships (id) on delete cascade,
  status public.application_status not null default 'saved',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, scholarship_id)
);

drop trigger if exists saved_scholarships_set_updated_at on public.saved_scholarships;
create trigger saved_scholarships_set_updated_at
  before update on public.saved_scholarships
  for each row execute function public.set_updated_at();

create index if not exists saved_scholarships_user_idx on public.saved_scholarships (user_id);

-- Row Level Security
alter table public.profiles enable row level security;
alter table public.scholarships enable row level security;
alter table public.saved_scholarships enable row level security;

-- profiles: owner only
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select to authenticated using ((select auth.uid()) = id);

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
  for insert to authenticated with check ((select auth.uid()) = id);

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

drop policy if exists profiles_delete_own on public.profiles;
create policy profiles_delete_own on public.profiles
  for delete to authenticated using ((select auth.uid()) = id);

-- scholarships: public read of active rows; writes via service role only
drop policy if exists scholarships_public_read on public.scholarships;
create policy scholarships_public_read on public.scholarships
  for select to anon, authenticated using (is_active = true);

-- saved_scholarships: owner only, all operations
drop policy if exists saved_owner_all on public.saved_scholarships;
create policy saved_owner_all on public.saved_scholarships
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- Eligibility matching
create or replace function public.match_scholarships(
  student_cgpa numeric,
  p_level text default null,
  p_field text default null,
  p_include_expired boolean default false
)
returns setof public.scholarships
language sql stable security invoker set search_path = '' as $$
  select s.*
  from public.scholarships s
  where s.is_active
    and s.min_cgpa <= student_cgpa
    and (s.max_cgpa is null or s.max_cgpa >= student_cgpa)
    and (p_level is null or s.level is null or s.level = p_level)
    and (p_field is null or s.field_of_study is null or s.field_of_study ilike p_field)
    and (p_include_expired or s.deadline is null or s.deadline >= current_date)
  order by s.deadline nulls last, s.min_cgpa desc;
$$;
