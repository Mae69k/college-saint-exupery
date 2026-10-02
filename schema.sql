-- ============================================================
-- Collège Saint-Exupéry — Schéma Supabase
-- À coller et exécuter dans Supabase > SQL Editor
-- ============================================================

-- Table des profils (rôle de chaque compte admin/staff)
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  role text not null check (role in ('superadmin','staff')),
  created_at timestamptz default now()
);

alter table profiles enable row level security;

-- Un utilisateur connecté peut lire son propre profil (et tous les profils, utile pour la liste du personnel)
create policy "profiles: lecture pour les connectés"
  on profiles for select
  to authenticated
  using (true);

-- Seul un superadmin peut modifier un profil (changer un rôle)
create policy "profiles: modification par superadmin"
  on profiles for update
  to authenticated
  using (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'))
  with check (true);

-- ============================================================
-- Table des demandes d'inscription élève
-- ============================================================
create table if not exists inscriptions (
  id bigint generated always as identity primary key,
  nom text not null,
  prenom text not null,
  discord_username text not null,
  age_rp int not null,
  classe text not null,
  motivations text not null,
  qualites text[] not null,
  defauts text[] not null,
  statut text not null default 'en_attente' check (statut in ('en_attente','accepte','refuse')),
  notes text default '',
  created_at timestamptz default now()
);

alter table inscriptions enable row level security;

-- N'importe qui (formulaire public) peut créer une demande
create policy "inscriptions: envoi public"
  on inscriptions for insert
  to anon
  with check (true);

-- Seuls les comptes connectés (staff) peuvent les lire
create policy "inscriptions: lecture staff"
  on inscriptions for select
  to authenticated
  using (true);

-- Le staff connecté peut changer le statut ou supprimer
create policy "inscriptions: modification staff"
  on inscriptions for update
  to authenticated
  using (true)
  with check (true);

create policy "inscriptions: suppression staff"
  on inscriptions for delete
  to authenticated
  using (true);

-- ============================================================
-- Table des candidatures de recrutement
-- ============================================================
create table if not exists recrutements (
  id bigint generated always as identity primary key,
  nom text not null,
  prenom text not null,
  discord_username text not null,
  role_demande text not null,
  age_rp int not null,
  motivations text not null,
  qualites text[] not null,
  defauts text[] not null,
  disponibilite_oral text not null,
  statut text not null default 'en_attente' check (statut in ('en_attente','accepte','refuse')),
  notes text default '',
  created_at timestamptz default now()
);

alter table recrutements enable row level security;

create policy "recrutements: envoi public"
  on recrutements for insert
  to anon
  with check (true);

create policy "recrutements: lecture staff"
  on recrutements for select
  to authenticated
  using (true);

create policy "recrutements: modification staff"
  on recrutements for update
  to authenticated
  using (true)
  with check (true);

create policy "recrutements: suppression staff"
  on recrutements for delete
  to authenticated
  using (true);
