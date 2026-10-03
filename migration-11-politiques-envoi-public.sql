-- ============================================================
-- Répare les politiques d'envoi public (formulaires élèves)
-- ------------------------------------------------------------
-- Symptôme : le formulaire d'inscription renvoie
-- "new row violates row-level security policy for table inscriptions"
-- alors que le formulaire de recrutement fonctionne.
-- ============================================================

-- 1. DIAGNOSTIC : liste les politiques actuellement actives.
--    (resultat à regarder : il doit y avoir une ligne
--     inscriptions | envoi public | INSERT | {anon})
select tablename, policyname, cmd, roles
from pg_policies
where schemaname = 'public'
order by tablename, policyname;

-- 2. RECONSTITUTION des politiques d'envoi public.

alter table inscriptions enable row level security;

drop policy if exists "inscriptions: envoi public" on inscriptions;

create policy "inscriptions: envoi public"
  on inscriptions for insert
  to anon, authenticated
  with check (true);

alter table recrutements enable row level security;

drop policy if exists "recrutements: envoi public" on recrutements;

create policy "recrutements: envoi public"
  on recrutements for insert
  to anon, authenticated
  with check (true);

-- 3. VÉRIFICATION : la liste doit maintenant contenir
--    inscriptions | envoi public | INSERT | {anon,authenticated}
select tablename, policyname, cmd, roles
from pg_policies
where schemaname = 'public'
  and policyname like '%envoi public%'
order by tablename;
