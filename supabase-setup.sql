-- Run this once in the Supabase SQL Editor for the project connected to the app.
-- Every authenticated user shares the same family challenge.

create table if not exists public.shared_challenge_state (
  challenge_id text primary key,
  state jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.shared_challenge_state enable row level security;

revoke all on public.shared_challenge_state from anon;
grant select, insert, update, delete on public.shared_challenge_state to authenticated;

drop policy if exists "Authenticated users can read shared challenge" on public.shared_challenge_state;
create policy "Authenticated users can read shared challenge"
  on public.shared_challenge_state for select
  to authenticated
  using (challenge_id = 'family');

drop policy if exists "Authenticated users can create shared challenge" on public.shared_challenge_state;
create policy "Authenticated users can create shared challenge"
  on public.shared_challenge_state for insert
  to authenticated
  with check (challenge_id = 'family');

drop policy if exists "Authenticated users can update shared challenge" on public.shared_challenge_state;
create policy "Authenticated users can update shared challenge"
  on public.shared_challenge_state for update
  to authenticated
  using (challenge_id = 'family')
  with check (challenge_id = 'family');

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'shared_challenge_state'
  ) then
    alter publication supabase_realtime add table public.shared_challenge_state;
  end if;
end $$;
