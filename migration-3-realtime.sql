-- ============================================================
-- MIGRATION 3 : activer la synchro temps réel
-- À coller et exécuter dans Supabase > SQL Editor
-- (à faire une seule fois)
-- ============================================================

alter publication supabase_realtime add table inscriptions;
alter publication supabase_realtime add table recrutements;
