// ============================================================
// Edge Function : manage-ecole-user
// À déployer avec la CLI Supabase
// Chemin attendu : supabase/functions/manage-ecole-user/index.ts
// ============================================================
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" }
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const callerClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: userErr } = await callerClient.auth.getUser();
    if (userErr || !user) return json({ error: "Non authentifié." }, 401);

    const { data: profile } = await callerClient.from("profiles").select("role").eq("id", user.id).single();
    if (!profile || profile.role !== "superadmin") return json({ error: "Réservé à l'Admin." }, 403);

    const adminClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const body = await req.json();

    // ---------- Création d'un compte élève / personnel ----------
    if (body.action === "create") {
      const { identifiant, password, nom, prenom, profil } = body;
      if (!identifiant || !password || !nom || !prenom || !profil) {
        return json({ error: "Tous les champs sont requis." }, 400);
      }

      const email = `${identifiant}@educollege-comptes.local`;
      const { data: created, error: createErr } = await adminClient.auth.admin.createUser({
        email, password, email_confirm: true
      });
      if (createErr) return json({ error: createErr.message }, 400);

      const { error: insertErr } = await adminClient.from("comptes_ecole").insert({
        id: created.user.id, identifiant, nom, prenom, profil
      });
      if (insertErr) return json({ error: insertErr.message }, 400);

      return json({ ok: true });
    }

    // ---------- Suppression d'un compte élève / personnel ----------
    if (body.action === "delete") {
      const { userId } = body;
      if (!userId) return json({ error: "userId requis." }, 400);

      const { error: deleteErr } = await adminClient.auth.admin.deleteUser(userId);
      if (deleteErr) return json({ error: deleteErr.message }, 400);

      await adminClient.from("comptes_ecole").delete().eq("id", userId);
      return json({ ok: true });
    }

    return json({ error: "Action inconnue." }, 400);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
