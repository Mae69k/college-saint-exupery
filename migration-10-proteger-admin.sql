-- ============================================================
-- Protection des comptes Admin contre la suppression accidentelle
-- (colonne utilisée par admin.html et par la fonction delete-staff-user)
-- ============================================================

alter table profiles add column if not exists is_protected boolean not null default false;

-- Tous les comptes Admin deviennent protégés : ils ne sont plus supprimables
-- depuis l'interface. Pour en dépublier un :
--   update profiles set is_protected = false where username = 'TON-EMAIL';
update profiles set is_protected = true where role = 'superadmin';
