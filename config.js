// ⚠️ À COMPLÉTER : remplace les deux valeurs ci-dessous par celles de ton projet Supabase.
// Tu les trouves dans Supabase > Project Settings > API.
// L'URL et la clé "anon public" ne sont PAS secrètes, elles sont faites pour être dans le code du site.
// Ne mets JAMAIS la clé "service_role" ici.

const SUPABASE_URL = "https://zgrzqjncvkccsxrzezsn.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpncnpxam5jdmtjY3N4cnplenNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkzMDM2NzMsImV4cCI6MjEwNDg3OTY3M30.5j7SVzg6_NeLWE7lPl8petMQKt4Xx1ZqxlYvuKgc0bY";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
