-- Cards Against Devs — Supabase Schema
-- Run this in your Supabase SQL editor

-- Enable realtime for all tables
create extension if not exists "uuid-ossp";

-- Rooms table
create table rooms (
  id uuid primary key default uuid_generate_v4(),
  code text unique not null,
  host_id text not null,
  phase text not null default 'lobby',   -- lobby | picking | judging | reveal | gameover
  round int not null default 0,
  max_rounds int not null default 10,
  win_score int not null default 7,
  judge_index int not null default 0,
  black_card text,
  created_at timestamptz default now()
);

-- Players table
create table players (
  id uuid primary key default uuid_generate_v4(),
  room_code text references rooms(code) on delete cascade,
  name text not null,
  score int not null default 0,
  is_host boolean default false,
  connected_at timestamptz default now()
);

-- Submissions table (per round)
create table submissions (
  id uuid primary key default uuid_generate_v4(),
  room_code text references rooms(code) on delete cascade,
  round int not null,
  player_name text not null,
  card_text text not null,
  is_winner boolean default false,
  submitted_at timestamptz default now()
);

-- Enable realtime
alter publication supabase_realtime add table rooms;
alter publication supabase_realtime add table players;
alter publication supabase_realtime add table submissions;

-- RLS policies (allow all for simplicity — tighten in prod)
alter table rooms enable row level security;
alter table players enable row level security;
alter table submissions enable row level security;

create policy "Public read rooms" on rooms for select using (true);
create policy "Public insert rooms" on rooms for insert with check (true);
create policy "Public update rooms" on rooms for update using (true);

create policy "Public read players" on players for select using (true);
create policy "Public insert players" on players for insert with check (true);
create policy "Public update players" on players for update using (true);
create policy "Public delete players" on players for delete using (true);

create policy "Public read submissions" on submissions for select using (true);
create policy "Public insert submissions" on submissions for insert with check (true);
create policy "Public update submissions" on submissions for update using (true);
