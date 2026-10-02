-- ============================================================
-- MIGRATION 4 : comptes élèves/personnel + protection Admin
-- À coller et exécuter dans Supabase > SQL Editor
-- (à faire une seule fois)
-- ============================================================

-- Table des comptes élèves / responsables / personnel / académie
create table if not exists comptes_ecole (
  id uuid primary key references auth.users(id) on delete cascade,
  identifiant text unique not null,
  nom text not null,
  prenom text not null,
  profil text not null check (profil in ('eleve','responsable','direction','profs','academie')),
  created_at timestamptz default now()
);

alter table comptes_ecole enable row level security;

-- Chacun peut lire son propre compte (pour afficher son espace personnel)
create policy "comptes_ecole: lecture de son propre compte"
  on comptes_ecole for select
  to authenticated
  using (auth.uid() = id);

-- L'Admin (superadmin) peut lire tous les comptes (pour la gestion dans l'admin)
create policy "comptes_ecole: lecture par admin"
  on comptes_ecole for select
  to authenticated
  using (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'));

-- ============================================================
-- Protection du compte Admin principal (ne peut jamais être supprimé)
-- ============================================================
alter table profiles add column if not exists is_protected boolean not null default false;

-- ⚠️ Remplace 'TON-EMAIL-ADMIN' par ton propre email pour te protéger toi-même
-- (le compte que tu as créé en tout premier, ton compte Admin principal)
update profiles set is_protected = true where username = 'TON-EMAIL-ADMIN';
