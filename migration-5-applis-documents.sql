-- ============================================================
-- MIGRATION 5 : favoris "Mes applis" + espace documentaire
-- À coller et exécuter dans Supabase > SQL Editor
-- (à faire une seule fois)
-- ============================================================

-- Colonne pour stocker les applis mises en favoris par chaque compte
alter table comptes_ecole add column if not exists favoris text[] default '{}';

-- Chacun peut modifier SES PROPRES favoris (et uniquement ça, grâce au with check)
create policy "comptes_ecole: modification de son propre compte"
  on comptes_ecole for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- ============================================================
-- Espace documentaire (stockage de fichiers privé par utilisateur)
-- ============================================================
insert into storage.buckets (id, name, public)
values ('espace-documentaire', 'espace-documentaire', false)
on conflict (id) do nothing;

-- Chacun ne peut voir/ajouter/supprimer que les fichiers dans SON PROPRE dossier
-- (dossier nommé automatiquement d'après son identifiant utilisateur)
create policy "espace_documentaire: acces prive par utilisateur"
  on storage.objects for all
  to authenticated
  using (bucket_id = 'espace-documentaire' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'espace-documentaire' and (storage.foldername(name))[1] = auth.uid()::text);
