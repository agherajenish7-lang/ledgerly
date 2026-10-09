-- Ledgerly V1 schema. Run once in Supabase → SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  type text not null check (type in ('income','expense')),
  description text not null check (char_length(description) between 1 and 120),
  amount numeric(14,2) not null check (amount > 0),
  date date not null,
  category text not null default 'Other',
  account text not null default '',
  notes text not null default '' check (char_length(notes) <= 240),
  created_at timestamptz not null default now()
);
create table if not exists public.budgets (
  id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  category text not null, amount numeric(14,2) not null check (amount > 0), created_at timestamptz not null default now(), unique(user_id,category)
);
create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null, target_amount numeric(14,2) not null check (target_amount > 0), current_amount numeric(14,2) not null default 0 check (current_amount >= 0), target_date date, created_at timestamptz not null default now()
);
create table if not exists public.recurring (
  id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null, amount numeric(14,2) not null check (amount > 0), frequency text not null check (frequency in ('Weekly','Monthly','Quarterly','Yearly')), next_date date, account text not null default '', created_at timestamptz not null default now()
);
create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null, amount numeric(14,2) not null check (amount > 0), frequency text not null check (frequency in ('Weekly','Monthly','Quarterly','Yearly')), next_date date, account text not null default '', created_at timestamptz not null default now()
);
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 50), created_at timestamptz not null default now(), unique(user_id,name)
);
create table if not exists public.accounts (
  id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 60), created_at timestamptz not null default now(), unique(user_id,name)
);

-- Enable owner-only access on every table. No service-role key is used in the app.
do $$ declare t text; begin
  foreach t in array array['transactions','budgets','goals','recurring','subscriptions','categories','accounts'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "Owner manages own %s" on public.%I', t, t);
    execute format('create policy "Owner manages own %s" on public.%I for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))', t, t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
  end loop;
end $$;

-- Indexes for common account and date queries.
create index if not exists transactions_user_date_idx on public.transactions(user_id,date desc);
create index if not exists budgets_user_idx on public.budgets(user_id);
create index if not exists goals_user_idx on public.goals(user_id);
create index if not exists recurring_user_idx on public.recurring(user_id);
create index if not exists subscriptions_user_idx on public.subscriptions(user_id);
