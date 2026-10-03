// ============================================================
// Edge Function : create-staff-user
// À déployer avec la CLI Supabase (mêmes étapes que delete-staff-user)
// Chemin attendu : supabase/functions/create-staff-user/index.ts
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
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const callerClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: userErr } = await callerClient.auth.getUser();
    if (userErr || !user) return json({ error: "Non authentifié." }, 401);

    const { data: profile } = await callerClient
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();

    if (!profile || profile.role !== "superadmin") {
      return json({ error: "Réservé au superadmin." }, 403);
    }

    const { username, password } = await req.json();
    if (!username || !password) return json({ error: "Identifiant et mot de passe requis." }, 400);
    if (String(password).length < 6) return json({ error: "Mot de passe : 6 caractères minimum." }, 400);

    const email = String(username).includes("@")
      ? String(username).trim().toLowerCase()
      : `${String(username).trim().toLowerCase()}@staff.educollege.local`;

    const adminClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: created, error: createErr } = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    });
    if (createErr) return json({ error: createErr.message }, 400);

    const { error: insertErr } = await adminClient.from("profiles").insert({
      id: created!.user.id,
      username: email,
      role: "staff",
    });

    if (insertErr) {
      // Ne laisse pas de compte Auth orphelin si le profil n'a pas pu être créé.
      await adminClient.auth.admin.deleteUser(created!.user.id);
      return json({ error: insertErr.message }, 400);
    }

    return json({ ok: true, email });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
