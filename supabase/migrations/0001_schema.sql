-- Sovereign: PostgreSQL Schema for Supabase
-- Every table includes id uuid pk default gen_random_uuid(),
-- user_id references auth.users not null default auth.uid(),
-- created_at timestamptz default now(), and RLS enabled.

-- 1. Tasks table
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null default auth.uid(),
  created_at timestamptz default now(),
  title text not null,
  notes text not null default '',
  priority text not null check (priority in ('low', 'medium', 'high')),
  due_at timestamptz,
  completed_at timestamptz
);

alter table public.tasks enable row level security;

create policy "Users can select own tasks"
  on public.tasks for select
  using (auth.uid() = user_id);

create policy "Users can insert own tasks"
  on public.tasks for insert
  with check (auth.uid() = user_id);

create policy "Users can update own tasks"
  on public.tasks for update
  using (auth.uid() = user_id);

create policy "Users can delete own tasks"
  on public.tasks for delete
  using (auth.uid() = user_id);

-- 2. Habits table
create table if not exists public.habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null default auth.uid(),
  created_at timestamptz default now(),
  name text not null,
  schedule integer[] not null default '{1,2,3,4,5,6,7}',
  archived_at timestamptz
);

alter table public.habits enable row level security;

create policy "Users can select own habits"
  on public.habits for select
  using (auth.uid() = user_id);

create policy "Users can insert own habits"
  on public.habits for insert
  with check (auth.uid() = user_id);

create policy "Users can update own habits"
  on public.habits for update
  using (auth.uid() = user_id);

create policy "Users can delete own habits"
  on public.habits for delete
  using (auth.uid() = user_id);

-- 3. Habit check-ins table
create table if not exists public.habit_checkins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null default auth.uid(),
  created_at timestamptz default now(),
  habit_id uuid not null references public.habits(id) on delete cascade,
  date date not null,
  unique (habit_id, date)
);

alter table public.habit_checkins enable row level security;

create policy "Users can select own habit_checkins"
  on public.habit_checkins for select
  using (auth.uid() = user_id);

create policy "Users can insert own habit_checkins"
  on public.habit_checkins for insert
  with check (auth.uid() = user_id);

create policy "Users can update own habit_checkins"
  on public.habit_checkins for update
  using (auth.uid() = user_id);

create policy "Users can delete own habit_checkins"
  on public.habit_checkins for delete
  using (auth.uid() = user_id);

-- 4. Focus sessions table
create table if not exists public.focus_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null default auth.uid(),
  created_at timestamptz default now(),
  task_id uuid references public.tasks(id) on delete set null,
  started_at timestamptz not null,
  duration_seconds integer not null,
  completed boolean not null default false
);

alter table public.focus_sessions enable row level security;

create policy "Users can select own focus_sessions"
  on public.focus_sessions for select
  using (auth.uid() = user_id);

create policy "Users can insert own focus_sessions"
  on public.focus_sessions for insert
  with check (auth.uid() = user_id);

create policy "Users can update own focus_sessions"
  on public.focus_sessions for update
  using (auth.uid() = user_id);

create policy "Users can delete own focus_sessions"
  on public.focus_sessions for delete
  using (auth.uid() = user_id);

-- 5. Workouts table
create table if not exists public.workouts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null default auth.uid(),
  created_at timestamptz default now(),
  name text,
  started_at timestamptz not null,
  ended_at timestamptz,
  notes text not null default ''
);

alter table public.workouts enable row level security;

create policy "Users can select own workouts"
  on public.workouts for select
  using (auth.uid() = user_id);

create policy "Users can insert own workouts"
  on public.workouts for insert
  with check (auth.uid() = user_id);

create policy "Users can update own workouts"
  on public.workouts for update
  using (auth.uid() = user_id);

create policy "Users can delete own workouts"
  on public.workouts for delete
  using (auth.uid() = user_id);

-- 6. Workout exercises table
create table if not exists public.workout_exercises (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null default auth.uid(),
  created_at timestamptz default now(),
  workout_id uuid not null references public.workouts(id) on delete cascade,
  name text not null,
  position integer not null default 0
);

alter table public.workout_exercises enable row level security;

create policy "Users can select own workout_exercises"
  on public.workout_exercises for select
  using (auth.uid() = user_id);

create policy "Users can insert own workout_exercises"
  on public.workout_exercises for insert
  with check (auth.uid() = user_id);

create policy "Users can update own workout_exercises"
  on public.workout_exercises for update
  using (auth.uid() = user_id);

create policy "Users can delete own workout_exercises"
  on public.workout_exercises for delete
  using (auth.uid() = user_id);

-- 7. Workout sets table
create table if not exists public.workout_sets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null default auth.uid(),
  created_at timestamptz default now(),
  workout_exercise_id uuid not null references public.workout_exercises(id) on delete cascade,
  set_number integer not null,
  reps integer not null check (reps > 0),
  weight numeric,
  unit text not null check (unit in ('kg', 'lb'))
);

alter table public.workout_sets enable row level security;

create policy "Users can select own workout_sets"
  on public.workout_sets for select
  using (auth.uid() = user_id);

create policy "Users can insert own workout_sets"
  on public.workout_sets for insert
  with check (auth.uid() = user_id);

create policy "Users can update own workout_sets"
  on public.workout_sets for update
  using (auth.uid() = user_id);

create policy "Users can delete own workout_sets"
  on public.workout_sets for delete
  using (auth.uid() = user_id);

-- 8. Planner blocks table
create table if not exists public.planner_blocks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null default auth.uid(),
  created_at timestamptz default now(),
  title text not null,
  task_id uuid references public.tasks(id) on delete set null,
  start_at timestamptz not null,
  end_at timestamptz not null check (end_at > start_at)
);

alter table public.planner_blocks enable row level security;

create policy "Users can select own planner_blocks"
  on public.planner_blocks for select
  using (auth.uid() = user_id);

create policy "Users can insert own planner_blocks"
  on public.planner_blocks for insert
  with check (auth.uid() = user_id);

create policy "Users can update own planner_blocks"
  on public.planner_blocks for update
  using (auth.uid() = user_id);

create policy "Users can delete own planner_blocks"
  on public.planner_blocks for delete
  using (auth.uid() = user_id);
