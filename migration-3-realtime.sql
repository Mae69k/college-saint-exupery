-- ============================================================
-- MIGRATION 3 : activer la synchro temps réel
-- À coller et exécuter dans Supabase > SQL Editor
-- (à faire une seule fois)
-- ============================================================
-- Chaque table est ajoutée sans échouer si elle est déjà dans la publication.

do $$
begin
  alter publication supabase_realtime add table inscriptions;
exception
  when duplicate_object then null;
  when undefined_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table recrutements;
exception
  when duplicate_object then null;
  when undefined_object then null;
end $$;