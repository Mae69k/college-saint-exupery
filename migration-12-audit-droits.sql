-- ============================================================
-- AUDIT + RÉPARATION complète des droits (RLS, bucket, temps réel)
-- ------------------------------------------------------------
-- À exécuter UNE FOIS dans Supabase > SQL Editor.
-- Sans risque : chaque politique est droppée puis recréée.
--
-- Pourquoi : certains scripts ont pu s'interrompre sur une erreur
-- (politique déjà existante), laissant des droits manquants.
-- Exemple constaté : le bucket "espace-documentaire" n'existait pas.
-- ============================================================

-- ---------- 1. DIAGNOSTIC (à lire avant) ----------
select tablename, policyname, cmd, roles
from pg_policies
where schemaname = 'public'
order by tablename, policyname;

select id, name, public from storage.buckets order by id;


-- ---------- 2. BUCKET DE L'ESPACE DOCUMENTAIRE ----------

insert into storage.buckets (id, name, public)
values ('espace-documentaire', 'espace-documentaire', false)
on conflict (id) do update set public = false;

drop policy if exists "espace_documentaire: acces prive par utilisateur" on storage.objects;

create policy "esspace_documentaire: acces prive par utilisateur"
  on storage.objects for all
  to authenticated
  using (bucket_id = 'espace-documentaire' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'espace-documentaire' and (storage.foldername(name))[1] = auth.uid()::text);


-- ---------- 3. TOUTES LES POLITIQUES, RECRÉÉES ----------

-- Profils
alter table profiles enable row level security;

drop policy if exists "profiles: lecture pour les connectés" on profiles;

create policy "profiles: lecture pour les connectés"
  on profiles for select
  to authenticated
  using (true);

drop policy if exists "profiles: modification par superadmin" on profiles;

create policy "profiles: modification par superadmin"
  on profiles for update
  to authenticated
  using (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'))
  with check (true);

-- Inscriptions élèves (formulaire public)
alter table inscriptions enable row level security;

drop policy if exists "inscriptions: envoi public" on inscriptions;

create policy "inscriptions: envoi public"
  on inscriptions for insert
  to anon, authenticated
  with check (true);

drop policy if exists "inscriptions: lecture staff" on inscriptions;

create policy "inscriptions: lecture staff"
  on inscriptions for select
  to authenticated
  using (true);

drop policy if exists "inscriptions: modification staff" on inscriptions;

create policy "inscriptions: modification staff"
  on inscriptions for update
  to authenticated
  using (true)
  with check (true);

drop policy if exists "inscriptions: suppression staff" on inscriptions;

create policy "inscriptions: suppression staff"
  on inscriptions for delete
  to authenticated
  using (true);

-- Recrutements (formulaire public)
alter table recrutements enable row level security;

drop policy if exists "recrutements: envoi public" on recrutements;

create policy "recrutements: envoi public"
  on recrutements for insert
  to anon, authenticated
  with check (true);

drop policy if exists "recrutements: lecture staff" on recrutements;

create policy "recrutements: lecture staff"
  on recrutements for select
  to authenticated
  using (true);

drop policy if exists "recrutements: modification staff" on recrutements;

create policy "recrutements: modification staff"
  on recrutements for update
  to authenticated
  using (true)
  with check (true);

drop policy if exists "recrutements: suppression staff" on recrutements;

create policy "recrutements: suppression staff"
  on recrutements for delete
  to authenticated
  using (true);

-- Comptes école
alter table comptes_ecole enable row level security;

drop policy if exists "comptes_ecole: lecture de son propre compte" on comptes_ecole;

create policy "comptes_ecole: lecture de son propre compte"
  on comptes_ecole for select
  to authenticated
  using (auth.uid() = id);

drop policy if exists "comptes_ecole: lecture par admin" on comptes_ecole;

create policy "comptes_ecole: lecture par admin"
  on comptes_ecole for select
  to authenticated
  using (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'));

drop policy if exists "comptes_ecole: annuaire des connectes" on comptes_ecole;

create policy "comptes_ecole: annuaire des connectes"
  on comptes_ecole for select
  to authenticated
  using (true);

drop policy if exists "comptes_ecole: modification par superadmin" on comptes_ecole;

create policy "comptes_ecole: modification par superadmin"
  on comptes_ecole for update
  to authenticated
  using (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'))
  with check (true);

drop policy if exists "comptes_ecole: modification de son propre compte" on comptes_ecole;

create policy "comptes_ecole: modification de son propre compte"
  on comptes_ecole for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Contenu du site (settings)
alter table settings enable row level security;

drop policy if exists "settings: lecture" on settings;

create policy "settings: lecture"
  on settings for select
  to authenticated
  using (true);

drop policy if exists "settings: lecture publique du contenu" on settings;

create policy "settings: lecture publique du contenu"
  on settings for select
  to anon
  using (key = 'contenu_site');

drop policy if exists "settings: insertion superadmin" on settings;

create policy "settings: insertion superadmin"
  on settings for insert
  to authenticated
  with check (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'));

drop policy if exists "settings: modification superadmin" on settings;

create policy "settings: modification superadmin"
  on settings for update
  to authenticated
  using (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'))
  with check (true);

-- Messagerie
alter table messages enable row level security;

drop policy if exists "messages: lecture de ses messages" on messages;

create policy "messages: lecture de ses messages"
  on messages for select
  to authenticated
  using (auth.uid() = sender_id or auth.uid() = receiver_id);

drop policy if exists "messages: envoi" on messages;

create policy "messages: envoi"
  on messages for insert
  to authenticated
  with check (auth.uid() = sender_id);

drop policy if exists "messages: marquer lu" on messages;

create policy "messages: marquer lu"
  on messages for update
  to authenticated
  using (auth.uid() = receiver_id)
  with check (auth.uid() = receiver_id);

drop policy if exists "messages: suppression de ses messages" on messages;

create policy "messages: suppression de ses messages"
  on messages for delete
  to authenticated
  using (auth.uid() = sender_id or auth.uid() = receiver_id);


-- ---------- 4. TEMPS RÉEL ----------

do $$
begin
  begin
    alter publication supabase_realtime add table messages;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table inscriptions;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table recrutements;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table comptes_ecole;
  exception when duplicate_object then null;
  end;
end $$;


-- ---------- 5. VÉRIFICATION ----------
-- Le bucket "espace-documentaire" doit apparaître,
-- et chaque table doit avoir ses politiques.

select tablename, policyname, cmd, roles
from pg_policies
where schemaname = 'public'
order by tablename, policyname;

select id, name, public from storage.buckets order by id;
