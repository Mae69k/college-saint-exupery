-- ============================================================
-- MIGRATION : statuts + droits de modification/suppression
-- À coller et exécuter dans Supabase > SQL Editor
-- (à faire une seule fois, tes tables existent déjà)
-- ============================================================

-- Ajoute une colonne statut aux deux tables
alter table inscriptions add column if not exists statut text not null default 'en_attente'
  check (statut in ('en_attente','accepte','refuse'));

alter table recrutements add column if not exists statut text not null default 'en_attente'
  check (statut in ('en_attente','accepte','refuse'));

-- Autorise le staff connecté à modifier le statut
create policy "inscriptions: modification staff"
  on inscriptions for update
  to authenticated
  using (true)
  with check (true);

create policy "recrutements: modification staff"
  on recrutements for update
  to authenticated
  using (true)
  with check (true);

-- Autorise le staff connecté à supprimer une candidature
create policy "inscriptions: suppression staff"
  on inscriptions for delete
  to authenticated
  using (true);

create policy "recrutements: suppression staff"
  on recrutements for delete
  to authenticated
  using (true);
