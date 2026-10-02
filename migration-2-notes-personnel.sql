-- ============================================================
-- MIGRATION 2 : notes internes + gestion des rôles
-- À coller et exécuter dans Supabase > SQL Editor
-- (à faire une seule fois, en plus de migration-statuts.sql)
-- ============================================================

-- Ajoute une colonne notes internes aux deux tables
alter table inscriptions add column if not exists notes text default '';
alter table recrutements add column if not exists notes text default '';

-- Autorise le staff connecté à modifier les notes (déjà couvert par la policy
-- "modification staff" de migration-statuts.sql si tu l'as déjà exécutée,
-- sinon exécute aussi migration-statuts.sql avant celle-ci)

-- Autorise un superadmin à modifier un profil (pour changer le rôle d'un compte)
create policy "profiles: modification par superadmin"
  on profiles for update
  to authenticated
  using (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'))
  with check (true);
