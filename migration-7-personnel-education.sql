-- ============================================================
-- MIGRATION 7 : nouveau profil "Personnel d'éducation" (CPE/AED)
-- À coller et exécuter dans Supabase > SQL Editor
-- (à faire une seule fois, après migration-6)
-- ============================================================

-- Ajuste la contrainte pour autoriser le nouveau profil 'education'
alter table comptes_ecole drop constraint if exists comptes_ecole_profil_check;
alter table comptes_ecole add constraint comptes_ecole_profil_check
  check (profil in ('eleve','responsable','direction','education','profs','academie'));