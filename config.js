// ⚠️ À COMPLÉTER : remplace les deux valeurs ci-dessous par celles de ton projet Supabase.
// Tu les trouves dans Supabase > Project Settings > API.
// L'URL et la clé "anon public" ne sont PAS secrètes, elles sont faites pour être dans le code du site.
// Ne mets JAMAIS la clé "service_role" ici.

const SUPABASE_URL = "https://xfavcidcalkhuceswhxj.supabase.co";
const SUPABASE_ANON_KEY = "A_COLLER_ICI";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
