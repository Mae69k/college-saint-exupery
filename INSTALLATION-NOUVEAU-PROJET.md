# Installer le nouveau projet Supabase (en 6 étapes)

Le projet Supabase a changé : l'ancien projet (`zgrzqjncvkccsxrzezsn`) est en pause,
le nouveau projet est `xfavcidcalkhuceswhxj`.

Un projet Supabase neuf est **vide** : il faut donc tout rejouer dans cet ordre.
L'URL du site (Vercel) ne change pas, seul `config.js` pointe vers le nouveau projet.

---

## Étape 1 — Récupérer la clé anon du nouveau projet

1. Ouvre ton nouveau projet sur [supabase.com](https://supabase.com).
2. Menu de gauche → **Project Settings → API**.
3. Copie **Project URL** et **anon public** (la clé qui commence par `eyJ...`).
4. Ouvre le fichier `config.js` du site et remplace :
   - `A_COLLER_ICI` par la clé anon public
   - (l'URL est déjà remplie : `https://xfavcidcalkhuceswhxj.supabase.co`)

⚠️ Ne mets **jamais** la clé `service_role` dans ce fichier.

## Étape 2 — Créer les tables

Dans **SQL Editor**, exécute ces fichiers dans cet ordre (un par un, dans l'ordre) :

1. `schema.sql` (les tables de base : inscriptions, recrutements, profiles)
2. `migration-statuts.sql` (statuts des candidatures)
3. `migration-2-notes-personnel.sql` (notes internes, rôles du personnel)
4. `migration-3-realtime.sql` (synchro en temps réel)
5. `migration-4-comptes-ecole.sql` ⚠️ remplace `'TON-EMAIL-ADMIN'` en bas du fichier par ton email
6. `migration-5-applis-documents.sql` (applis + espace documentaire)
7. `migration-6-messagerie-maintenance.sql` (messagerie, horaires, maintenance)
8. `migration-7-personnel-education.sql` (profils du personnel)
9. `migration-8-contenu-site.sql` (contenu modifiable depuis l'espace admin)
10. `migration-9-questions-recrutement.sql` (5 questions de recrutement + date)

## Étape 3 — Recréer ton compte superadmin

1. **Authentication → Users → Add user** : ton email, ton mot de passe, **Auto Confirm User** coché.
2. Copie l'UUID affiché sur la fiche du user (sans les `< >`).
3. Dans **SQL Editor** :

```sql
insert into profiles (id, username, role)
values ('UUID_ICI', 'ton-email@exemple.com', 'superadmin');
```

## Étape 4 — Recréer les comptes école (élèves, profs…)

Ils ne sont pas récupérés automatiquement. Refais-les depuis
`admin.html` → onglet **Comptes École** (une fois ton compte superadmin connecté).
Si tu veux repartir de l'ancien projet, tu peux d'abord le relancer
(Projects → ancien projet → Resume) puis exporter les données.

## Étape 5 — Redéployer les deux fonctions serveur

```bash
npm install -g supabase
supabase login
supabase link --project-ref xfavcidcalkhuceswhxj
supabase functions deploy manage-ecole-user
supabase functions deploy delete-staff-user
```

## Étape 6 — Vérifier

1. Ouvre le site → **Se connecter** avec ton compte superadmin.
2. Tu dois arriver sur `admin.html`.
3. Onglet **Contenu du site** : ajoute une annonce, elle doit apparaître sur l'accueil.

---

## Où est passé l'ancien projet ?

Il n'est pas supprimé : il est **en pause** et peut être relancé jusqu'au
**26 octobre 2027** (Projects → projet en pause → Resume). Tu pourras alors
ré exporter les données et les réimporter dans le nouveau projet si besoin.

## Anti-pause

`.github/workflows/keep-supabase-active.yml` interroge le projet configuré dans
`config.js` toutes les 72 h. Dès que la clé est mise, il protège le nouveau projet.
Tu peux le lancer à la main : onglet **Actions** du dépôt → *Keep Supabase active* → *Run workflow*.
