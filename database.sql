-- Run in the Supabase SQL editor. All progress rows belong to their authenticated user.
create table if not exists public.user_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id text not null check (lesson_id ~ '^lesson-([1-9]|[1-5][0-9]|60)$'),
  completed boolean not null default false,
  completed_at timestamptz,
  primary key (user_id,lesson_id)
);
create table if not exists public.quiz_attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id text not null check (lesson_id ~ '^lesson-([1-9]|[1-5][0-9]|60)$'),
  score integer not null check (score between 0 and 100),
  passed boolean not null,
  answers jsonb not null,
  submitted_at timestamptz not null default now()
);
create index if not exists quiz_attempts_user_time on public.quiz_attempts(user_id,submitted_at desc);
alter table public.user_progress enable row level security;
alter table public.quiz_attempts enable row level security;
create policy "Read own progress" on public.user_progress for select to authenticated using ((select auth.uid())=user_id);
create policy "Insert own progress" on public.user_progress for insert to authenticated with check ((select auth.uid())=user_id);
create policy "Update own progress" on public.user_progress for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "Read own attempts" on public.quiz_attempts for select to authenticated using ((select auth.uid())=user_id);
create policy "Insert own attempts" on public.quiz_attempts for insert to authenticated with check ((select auth.uid())=user_id);
