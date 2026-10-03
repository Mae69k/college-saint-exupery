-- ============================================================
-- MIGRATION 8 : gestion du contenu du site depuis l'espace admin
-- À coller et exécuter dans Supabase > SQL Editor
-- (à faire une seule fois, après migration-6)
-- ============================================================
-- L'onglet « Contenu du site » de admin.html enregistre les annonces,
-- événements, informations importantes et chiffres du collège dans la
-- table settings, clé "contenu_site".
-- Cette migration autorise la lecture de cette clé par les visiteurs
-- (pages publiques : accueil, actualités, agenda).

-- Lecture publique de la clé contenu_site uniquement
drop policy if exists "settings: lecture publique du contenu du site" on settings;

create policy "settings: lecture publique du contenu du site"
  on settings for select
  to anon
  using (key = 'contenu_site');

-- Contenu d'exemple initial (modifiable ensuite depuis l'espace admin)
insert into settings (key, value)
values ('contenu_site', '{
  "actualites": [
    {"date": "[Exemple : 01/10/2026]", "titre": "[Exemple - Rentrée scolaire]", "description": "[Exemple - Informations relatives à la rentrée. Données à titre d''exemple uniquement.]"},
    {"date": "[Exemple : 15/10/2026]", "titre": "[Exemple - Sortie pédagogique]", "description": "[Exemple - Annonce à titre indicatif. Données à titre d''exemple uniquement.]"},
    {"date": "[Exemple : 05/11/2026]", "titre": "[Exemple - Activité du collège]", "description": "[Exemple - Actualité modifiable depuis l''espace d''administration.]"}
  ],
  "evenements": [
    {"date": "[Exemple : 08/10/2026]", "heure": "[Ex. 14h00]", "titre": "[Exemple - Réunion de rentrée]", "lieu": "[Exemple - Salle]", "description": "[Exemple - Description à titre indicatif.]"},
    {"date": "[Exemple : 22/10/2026]", "heure": "[Ex. 10h00]", "titre": "[Exemple - Sortie pédagogique]", "lieu": "[Exemple - Extérieur]", "description": "[Exemple - Description à titre indicatif.]"},
    {"date": "[Exemple : 12/11/2026]", "heure": "[Ex. 09h00]", "titre": "[Exemple - Conseil de classe]", "lieu": "[Exemple - Salle de réunion]", "description": "[Exemple - Description à titre indicatif.]"}
  ],
  "infos": [
    {"date": "[Exemple : 01/10/2026]", "titre": "[Exemple - Information importante]", "texte": "[Exemple - Annonce importante à titre d''exemple uniquement.]"}
  ],
  "stats": {"eleves": "[Ex.]", "personnels": "[Ex.]", "classes": "[Ex.]", "matieres": "[Ex.]"}
}'::jsonb)
on conflict (key) do nothing;