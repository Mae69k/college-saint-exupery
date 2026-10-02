-- ============================================================
-- MIGRATION 6 : messagerie interne + maintenance + 1er login
-- À coller et exécuter dans Supabase > SQL Editor
-- (à faire une seule fois, après migration-5)
-- ============================================================

-- ============================================================
-- Colonnes utilitaires sur les comptes école
-- ============================================================

-- maintenance : le superadmin peut bloquer l'accès d'un compte
alter table comptes_ecole add column if not exists maintenance boolean not null default false;

-- first_login : vrai tant que l'utilisateur n'a pas changé son mot de passe
alter table comptes_ecole add column if not exists first_login boolean not null default true;

-- ============================================================
-- Table des réglages globaux (plage horaire de la messagerie…)
-- ============================================================
create table if not exists settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz default now()
);

alter table settings enable row level security;

-- Tout le monde connecté peut lire les réglages (utile pour la messagerie)
create policy "settings: lecture"
  on settings for select
  to authenticated
  using (true);

-- Seul le superadmin peut modifier les réglages
create policy "settings: modification superadmin"
  on settings for update
  to authenticated
  using (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'))
  with check (true);

create policy "settings: insertion superadmin"
  on settings for insert
  to authenticated
  with check (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'));

-- Valeur par défaut : messagerie ouverte de 7h à 20h
insert into settings (key, value)
values ('messagerie_horaires', '{"debut": 7, "fin": 20}'::jsonb)
on conflict (key) do nothing;

-- ============================================================
-- Table des messages
-- ============================================================

-- Annuaire : chaque compte connecté peut voir les autres comptes
-- (id, identifiant, nom, prenom, profil) pour pouvoir envoyer des messages
create policy "comptes_ecole: annuaire des connectes"
  on comptes_ecole for select
  to authenticated
  using (true);

-- Le superadmin peut modifier tout compte école (maintenance, etc.)
create policy "comptes_ecole: modification par superadmin"
  on comptes_ecole for update
  to authenticated
  using (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'))
  with check (true);

create table if not exists messages (
  id bigint generated always as identity primary key,
  sender_id uuid not null references auth.users(id) on delete cascade,
  receiver_id uuid not null references auth.users(id) on delete cascade,
  content text not null check (char_length(content) between 1 and 2000),
  read boolean not null default false,
  created_at timestamptz default now()
);

alter table messages enable row level security;

-- Un utilisateur peut lire les messages qu'il a envoyés ou reçus
create policy "messages: lecture de ses messages"
  on messages for select
  to authenticated
  using (auth.uid() = sender_id or auth.uid() = receiver_id);

-- Un utilisateur peut envoyer un message s'il en est l'émetteur
create policy "messages: envoi"
  on messages for insert
  to authenticated
  with check (auth.uid() = sender_id);

-- Marquer un message comme lu (seul le destinataire)
create policy "messages: marquer lu"
  on messages for update
  to authenticated
  using (auth.uid() = receiver_id)
  with check (auth.uid() = receiver_id);

-- Chacun peut supprimer ses propres messages (reçus ou envoyés)
create policy "messages: suppression de ses messages"
  on messages for delete
  to authenticated
  using (auth.uid() = sender_id or auth.uid() = receiver_id);

alter publication supabase_realtime add table messages;