-- ============================================================
-- MIGRATION 9 : questions détaillées du formulaire de recrutement
-- À coller et exécuter dans Supabase > SQL Editor
-- (à faire une seule fois)
-- ============================================================
-- Le formulaire recrutement.html pose désormais 5 questions supplémentaires
-- (compétences, missions, travail en équipe, situation difficile,
-- contraintes) et demande une date de disponibilité pour l'oral.
-- Les réponses sont stockées dans ces nouvelles colonnes.

alter table recrutements add column if not exists competences text not null default '';
alter table recrutements add column if not exists missions text not null default '';
alter table recrutements add column if not exists equipe text not null default '';
alter table recrutements add column if not exists difficile text not null default '';
alter table recrutements add column if not exists contraintes text not null default '';

-- Si la colonne disponibilite_oral contient encore "oui" / "non"
-- (ancienne version du formulaire), on la Vide pour la remplacer par la date.
update recrutements
set disponibilite_oral = ''
where disponibilite_oral in ('oui', 'non', 'Oui', 'Non');