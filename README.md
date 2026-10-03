# Collège Saint-Exupéry — Site formulaires

3 pages : `inscription.html`, `recrutement.html`, `admin.html`.
Backend : Supabase (base de données + authentification).

## Pourquoi ces étapes sont nécessaires

Ton mot de passe (`Maeron.StExupery#26`) ne doit **jamais** apparaître en clair
dans un fichier HTML — sinon n'importe qui ouvrant le code source du site le
verrait. Supabase gère l'authentification à ta place : ton mot de passe est
transformé en une empreinte illisible (hashée) et stocké de façon sécurisée.
C'est pour ça qu'on crée ton compte directement dans Supabase, pas dans le code.

---

## Étape 1 — Créer le projet Supabase

1. Va sur [supabase.com](https://supabase.com), crée un compte gratuit puis un nouveau projet.
2. Note bien un mot de passe de base de données (différent du tien) qu'on te demande à la création.

## Étape 2 — Créer les tables

1. Dans le menu de gauche, ouvre **SQL Editor**.
2. Colle tout le contenu du fichier `schema.sql` fourni, puis clique sur **Run**.

## Étape 3 — Récupérer tes clés API

1. Va dans **Project Settings → API**.
2. Copie **Project URL** et **anon public key**.
3. Ouvre `config.js` et remplace :
  - `SUPABASE_URL` par ton Project URL
  - `SUPABASE_ANON_KEY` par ta clé anon public

Ces deux valeurs ne sont pas secrètes, elles sont faites pour être dans le code du site.

## Étape 4 — Créer ton compte superadmin

1. Va dans **Authentication → Users → Add user**.
2. Email : ton vrai email (ex. `mmalartre.prof@gmail.com`)
3. Mot de passe : celui de ton choix
4. Coche **Auto Confirm User**, puis crée le compte.
5. Retourne dans **SQL Editor** et exécute cette requête pour te donner le rôle superadmin
  (remplace `UUID_ICI` par l'UID affiché sur la fiche du user, visible dans Authentication → Users —
  **sans les chevrons `< >`**, juste l'UUID brut) :

```sql
insert into profiles (id, username, role)
values ('UUID_ICI', 'ton-email@exemple.com', 'superadmin');
```

Tu pourras dès lors te connecter sur `admin.html` avec ton email et ton mot de passe.

## Étape 5 — Déployer la fonction de création de compte staff

C'est ce qui permet au superadmin de créer des comptes staff **depuis le site**, en sécurité (la clé secrète ne touche jamais le navigateur).

1. Installe la CLI Supabase si ce n'est pas déjà fait : `npm install -g supabase`
2. Depuis un dossier de travail : `supabase login`, puis `supabase link --project-ref TON-PROJECT-REF` (le ref est dans l'URL de ton dashboard Supabase)
3. Crée le dossier `supabase/functions/create-staff-user/` et mets-y le fichier `edge-function-create-staff-user.ts` fourni, renommé en `index.ts`.
4. Déploie : `supabase functions deploy create-staff-user`

La fonction utilise automatiquement `SUPABASE_URL` et `SUPABASE_SERVICE_ROLE_KEY`, déjà disponibles côté Supabase — tu n'as rien à configurer de plus.

---

## Mise à jour — Statuts, filtres et suppression

Si ton site tournait déjà avant cette fonctionnalité, va dans **SQL Editor** sur Supabase et exécute tout le contenu du fichier `migration-statuts.sql` fourni (une seule fois). Ça ajoute :
- une colonne "statut" (en attente / accepté / refusé) sur chaque formulaire
- le droit pour le staff connecté de modifier ce statut et de supprimer une candidature

## Mise à jour — Notes internes et gestion du personnel

1. Exécute `migration-2-notes-personnel.sql` dans **SQL Editor** (ajoute les notes internes + le droit pour un superadmin de changer le rôle d'un compte).
2. Déploie une nouvelle fonction, exactement comme pour `create-staff-user` (voir étape 5 plus haut) :
  - Crée le dossier `supabase/functions/delete-staff-user/`
  - Mets-y le fichier `edge-function-delete-staff-user.ts` fourni, renommé en `index.ts`
  - Déploie : `supabase functions deploy delete-staff-user`

---

## Mise à jour — Synchro en temps réel

Exécute `migration-3-realtime.sql` dans **SQL Editor** (une seule fois). Ça active la synchro automatique : si quelqu'un change un statut, ajoute une note ou supprime une candidature depuis un autre écran, ça apparaît instantanément chez toi sans recharger la page. Un bouton "Enregistrer la note" devient vert 3 secondes avec "✓ Note ajoutée" quand ça marche.

---

## Mise à jour — Connexion élèves / personnel / académie (EduCollège)

Nouveau parcours de connexion complet, façon EduConnect rebrandé "EduCollège" :
`connexion-type.html` → `connexion-profil.html` → `connexion.html` → `espace.html`

**1. Ajoute 3 images dans `assets/`** (fournies par toi) :
- `exucollege_logo_fond_blanc.png`
- `logo_seul_educ_national.png`
- `logo_educ_national.png`

**2. Exécute `migration-4-comptes-ecole.sql`** dans SQL Editor. ⚠️ Avant de l'exécuter, remplace `'TON-EMAIL-ADMIN'` en bas du fichier par ton propre email (celui de ton compte Admin), pour te protéger toi-même contre une suppression accidentelle.

**3. Déploie une nouvelle fonction** `manage-ecole-user` (mêmes étapes que d'habitude) :
- Crée `supabase/functions/manage-ecole-user/`
- Mets-y `edge-function-manage-ecole-user.ts` renommé en `index.ts`
- `supabase functions deploy manage-ecole-user`

**4. Redéploie `delete-staff-user`** (le fichier a changé pour gérer la protection Admin) :
- Remplace `supabase/functions/delete-staff-user/index.ts` par le nouveau fichier
- `supabase functions deploy delete-staff-user`

Ensuite, dans `admin.html`, un nouvel onglet **"Comptes École"** permet de créer des comptes Élève / Responsable / Personnel de la Direction / Personnel d'éducation (CPE, AED) / Personnel enseignant / Académie, avec un identifiant + mot de passe. Ces comptes se connectent via le bouton "Se connecter" sur l'accueil, suivent le parcours à 3 écrans, et atterrissent sur `espace.html`, leur espace personnel.

Les rôles du panneau "Gestion du personnel" (celui du site admin lui-même) s'affichent maintenant comme **Personnel** / **Admin** au lieu de staff/superadmin. Un compte marqué "protégé" ne peut ni être rétrogradé ni supprimé, même par un autre Admin.

---

## Mise à jour — Mes applis (profs) + Espace documentaire

Exécute `migration-5-applis-documents.sql` dans **SQL Editor** (une seule fois). Ça ajoute :
- une colonne "favoris" sur les comptes école, pour que chaque prof garde ses applis favorites
- un bucket de stockage privé `espace-documentaire`, avec un dossier isolé par utilisateur (personne ne peut voir les fichiers d'un autre)

Aucune nouvelle fonction à déployer cette fois, tout passe par les tables/policies + le stockage Supabase directement.

Nouvelles pages : `mes-applis.html` (grille d'outils avec Pronote et GeoGebra en vrais liens, plus quelques autres outils, et un système de favoris) et `espace-documentaire.html` (glisser-déposer de fichiers, stockage persistant privé). Un lien "Mes outils" apparaît automatiquement sur `espace.html` pour les comptes de profil **Personnel enseignant**.

---

## Mise à jour — Messagerie interne, maintenance, 1er login

Exécute `migration-6-messagerie-maintenance.sql` dans **SQL Editor** (une seule fois). Ça ajoute :
- une table `messages` (messagerie entre élèves, profs et direction, avec temps réel et marquage lu / non lu)
- une table `settings` pour régler globalement les **horaires d'ouverture de la messagerie** (7h-20h par défaut) — en dehors de cette plage, aucun message ne peut être envoyé
- un flag `maintenance` sur les comptes école : un compte en maintenance ne peut plus se connecter tant qu'il n'est pas levé
- un flag `first_login` sur les comptes école : au premier login, l'utilisateur doit **changer son mot de passe** avant d'accéder à son espace (les comptes Admin `profiles` sont exemptés, ils passent directement sur `admin.html`)

Nouvelle page `messagerie.html` (liste de contacts + conversation). L'onglet **"Messagerie"** de `admin.html` (visible uniquement pour le superadmin) permet de régler les heures d'ouverture et de mettre des comptes en maintenance (bouton ⚠ dans "Comptes École").

Note : les comptes Admin (`profiles`) peuvent désormais se connecter via le parcours EduCollège (ex. profil "Personnel de la Direction") — ils sont automatiquement redirigés vers `admin.html`.

---

## Mise à jour — Contenu du site (annonces, agenda, chiffres)

Exécute `migration-8-contenu-site.sql` dans **SQL Editor** (une seule fois). Ça autorise les visiteurs (non connectés) à lire le contenu du site. L'écriture reste réservée au superadmin.

Ensuite, dans `admin.html`, l'onglet **"Contenu du site"** (visible uniquement pour le superadmin) permet de :
- ajouter, modifier, supprimer les **annonces / informations importantes**
- ajouter, modifier, supprimer les **actualités**
- ajouter, modifier, supprimer les **événements de l'agenda**
- modifier les **chiffres** du collège (élèves, personnels, classes, matières)
- exporter / importer le contenu en JSON, ou rétablir les exemples

Un bouton "Contenu du site" apparaît aussi sur `espace.html` pour les comptes superadmin.

Le contenu est enregistré dans la table `settings` (clé `contenu_site`) et s'affiche automatiquement sur l'accueil, `actualites.html` et `agenda.html`. Tant que la migration n'est pas exécutée, les pages publiques affichent les données d'exemple, mais l'enregistrement depuis l'espace admin fonctionne déjà.

---

## Mise à jour — Questions de recrutement + agenda calendrier

**1. Exécute `migration-9-questions-recrutement.sql`** dans **SQL Editor** (une seule fois). Ça ajoute les colonnes qui stockent les 5 réponses détaillées du formulaire de recrutement (compétences, missions, travail en équipe, situation difficile, contraintes).

Sans cette migration, le formulaire fonctionne quand même : si les colonnes manquent, la candidature est enregistrée sans ces 5 réponses et un message le signale à l'élève (aucune candidature n'est jamais perdue).

**2. Formulaire de recrutement** : la question « Disponibilité pour un recrutement à l'oral » (oui/non) est remplacée par une **date obligatoire**. Les 5 réponses s'affichent ensuite dans l'onglet « Recrutements » de `admin.html`.

**3. `agenda.html`** dispose maintenant d'un **v Calendrier mensuel** (mois précédent / suivant / aujourd'hui), les événements apparaissent directement dans les cases du jour. La liste complète reste en dessous de la grille.

---

## Pause du projet Supabase (gratuit)

Un projet Supabase en formule gratuite est **mis en pause après 7 jours sans activité**. Les données ne sont pas perdues : le projet se relance depuis le dashboard (bouton **Resume / Restore project**), et c'est possible jusqu'au 26 octobre 2027.

Pendant une pause, la page du site reste visible mais plus rien ne fonctionne : connexion, formulaires, messagerie, espace admin et contenu du site.

Deux précautions prises :

- `.github/workflows/keep-supabase-active.yml` envoie une requête à Supabase toutes les 72 heures (depuis le dépôt GitHub, sans clé secrète) pour éviter une nouvelle pause. Tu peux le lancer à la main depuis l'onglet **Actions** du dépôt.
- Les pages publiques restent lisibles même sans base de données : l'accueil, les actualités et l'agenda basculent sur les données d'exemple.

Si tu utilises réellement le site, l'activité des visiteurs compte déjà. Une alternative fiable : passer le projet en formule Pro.

---

## Nouveau projet Supabase

Si le projet a changé d'URL (`...supabase.co`), le nouveau projet est vide : suis `INSTALLATION-NOUVEAU-PROJET.md` pour tout réinstaller dans l'ordre (tables, superadmin, comptes école, fonctions serveur). Un projet en pause n'est pas perdu : il se relance jusqu'au 26 octobre 2027.

---

## Utilisation au quotidien

- **Élèves** → `inscription.html`
- **Candidats staff** → `recrutement.html`
- **Toi (et le personnel de direction)** → `admin.html` : consultation des deux formulaires, et onglet "Gestion du personnel" (visible uniquement pour toi, le superadmin) pour créer de nouveaux comptes staff avec identifiant + mot de passe.

## Fichiers du projet

```
site/
├── inscription.html
├── recrutement.html
├── admin.html
├── style.css
├── config.js             ← à compléter (étape 3)
├── schema.sql             ← à exécuter dans Supabase (étape 2)
├── edge-function-create-staff-user.ts ← à déployer (étape 5)
└── assets/
  ├── favicon.png
  └── logo.png
```
"# sitecse" 
