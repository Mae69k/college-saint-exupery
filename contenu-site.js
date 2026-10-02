// ============================================================
// Contenu du site (actualités, événements, infos importantes, chiffres)
// ------------------------------------------------------------
// Source de vérité : table Supabase "settings", clé "contenu_site".
// Écriture : uniquement depuis l'espace d'administration (superadmin).
// Lecture : pages publiques (accueil, actualités, agenda).
// Repli automatique : cache navigateur, puis données d'exemple ci-dessous.
// ============================================================

const CONTENU_KEY = 'contenu_site';

const CONTENU_CACHE = 'cse_contenu_site';



const CONTENU_DEFAUT = {

  actualites: [

    { date: '[Exemple : 01/10/2026]', titre: '[Exemple - Rentrée scolaire]', description: "[Exemple - Informations relatives à la rentrée. Données à titre d'exemple uniquement.]" },

    { date: '[Exemple : 15/10/2026]', titre: '[Exemple - Sortie pédagogique]', description: "[Exemple - Annonce à titre indicatif. Données à titre d'exemple uniquement.]" },

    { date: '[Exemple : 05/11/2026]', titre: '[Exemple - Activité du collège]', description: "[Exemple - Actualité modifiable depuis l'espace d'administration.]" }

  ],

  evenements: [

    { date: '[Exemple : 08/10/2026]', heure: '[Ex. 14h00]', titre: '[Exemple - Réunion de rentrée]', lieu: '[Exemple - Salle]', description: '[Exemple - Description à titre indicatif.]' },

    { date: '[Exemple : 22/10/2026]', heure: '[Ex. 10h00]', titre: '[Exemple - Sortie pédagogique]', lieu: '[Exemple - Extérieur]', description: '[Exemple - Description à titre indicatif.]' },

    { date: '[Exemple : 12/11/2026]', heure: '[Ex. 09h00]', titre: '[Exemple - Conseil de classe]', lieu: '[Exemple - Salle de réunion]', description: '[Exemple - Description à titre indicatif.]' }

  ],

  infos: [

    { date: '[Exemple : 01/10/2026]', titre: '[Exemple - Information importante]', texte: "[Exemple - Annonce importante à titre d'exemple uniquement.]" }

  ],

  stats: { eleves: '[Ex.]', personnels: '[Ex.]', classes: '[Ex.]', matieres: '[Ex.]' }

};



// Client Supabase : réutilise celui de la page si elle en a déjà un.

function contenuClient() {

  if (typeof supabaseClient !== 'undefined' && supabaseClient) return supabaseClient;

  if (!window.__cseClient && window.supabase && typeof SUPABASE_URL !== 'undefined') {

    window.__cseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

  }

  return window.__cseClient || null;

}



function contenuNormaliser(data) {

  const source = data && typeof data === 'object' ? data : {};

  return {

    actualites: Array.isArray(source.actualites) ? source.actualites : CONTENU_DEFAUT.actualites.slice(),

    evenements: Array.isArray(source.evenements) ? source.evenements : CONTENU_DEFAUT.evenements.slice(),

    infos: Array.isArray(source.infos) ? source.infos : CONTENU_DEFAUT.infos.slice(),

    stats: Object.assign({}, CONTENU_DEFAUT.stats, source.stats || {})

  };

}



async function chargerContenu() {

  const client = contenuClient();

  if (client) {

    const { data, error } = await client

      .from('settings')

      .select('value')

      .eq('key', CONTENU_KEY)

      .maybeSingle();

    if (!error && data && data.value) {

      const contenu = contenuNormaliser(data.value);

      try { localStorage.setItem(CONTENU_CACHE, JSON.stringify(contenu)); } catch (e) {}

      return contenu;

    }

  }

  try {

    const cache = localStorage.getItem(CONTENU_CACHE);

    if (cache) return contenuNormaliser(JSON.parse(cache));

  } catch (e) {}

  return contenuNormaliser(CONTENU_DEFAUT);

}



// Sauvegarde : tente Supabase (compte superadmin connecté), sinon cache local.

async function sauverContenu(contenu) {

  const clean = contenuNormaliser(contenu);

  clean.updated_at = new Date().toISOString();

  try { localStorage.setItem(CONTENU_CACHE, JSON.stringify(clean)); } catch (e) {}

  const client = contenuClient();

  if (!client) {

    return { ok: false, mode: 'local', message: 'Enregistré sur cet appareil uniquement (Supabase indisponible).' };

  }

  const { data: session } = await client.auth.getSession();

  if (!session) {

    return { ok: false, mode: 'local', message: 'Enregistré sur cet appareil uniquement : connecte-toi avec un compte administrateur pour publier sur le site.' };

  }

  const { error } = await client

    .from('settings')

    .upsert({ key: CONTENU_KEY, value: clean, updated_at: clean.updated_at });

  if (error) {

    return { ok: false, mode: 'local', message: 'Enregistré sur cet appareil uniquement. Erreur Supabase : ' + error.message };

  }

  return { ok: true, mode: 'supabase', message: 'Contenu publié sur le site.' };

}



// Évite d'injecter du HTML saisi dans les pages publiques.

function echapperTexte(str) {

  return String(str ?? '').replace(/[&<>"']/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[m]));

}



window.CONTENU_KEY = CONTENU_KEY;

window.CONTENU_DEFAUT = CONTENU_DEFAUT;

window.echapperTexte = echapperTexte;

window.chargerContenu = chargerContenu;

window.sauverContenu = sauverContenu;