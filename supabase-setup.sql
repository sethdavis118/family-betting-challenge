-- Run this once in the Supabase SQL Editor for the project connected to the app.
-- Each signed-in account owns one private challenge state.

create table if not exists public.challenge_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.challenge_state enable row level security;

revoke all on public.challenge_state from anon;
grant select, insert, update, delete on public.challenge_state to authenticated;

drop policy if exists "Users can read their challenge" on public.challenge_state;
create policy "Users can read their challenge"
  on public.challenge_state for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can create their challenge" on public.challenge_state;
create policy "Users can create their challenge"
  on public.challenge_state for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their challenge" on public.challenge_state;
create policy "Users can update their challenge"
  on public.challenge_state for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete their challenge" on public.challenge_state;
create policy "Users can delete their challenge"
  on public.challenge_state for delete
  to authenticated
  using ((select auth.uid()) = user_id);

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'challenge_state'
  ) then
    alter publication supabase_realtime add table public.challenge_state;
  end if;
end $$;
