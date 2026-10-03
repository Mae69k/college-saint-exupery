-- ============================================================
-- DIAGNOSTIC + RÉPARATION du compte superadmin
-- À coller et exécuter dans Supabase > SQL Editor
-- ============================================================

-- 1. REGARDE : la première requête liste tous tes comptes Auth
--    et le rôle associé dans la table profiles.
--    → Si la colonne "role" est vide : il manque la ligne de profil.
--    → Si elle vaut "staff" : le compte n'a pas été promu.
select
  u.email,
  u.email_confirmed_at,
  p.role,
  (p.id is not null) as profil_present
from auth.users u
left join profiles p on p.id = u.id
order by u.created_at;

-- 2. RÉPARE : remplace TON-EMAIL par ton vrai email (en minuscules),
--    puis exécute ces deux requêtes.
--    (elles sont sans danger si c'est déjà fait)

update profiles
set role = 'superadmin'
where id = (select id from auth.users where lower(email) = 'ton-email@exemple.com');

insert into profiles (id, username, role)
select id, email, 'superadmin'
from auth.users
where lower(email) = 'ton-email@exemple.com'
on conflict (id) do update set role = 'superadmin';

-- 3. VÉRIFIE
select u.email, p.role
from auth.users u
join profiles p on p.id = u.id;
