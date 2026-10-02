// ============================================================
// Edge Function : delete-staff-user
// À déployer avec la CLI Supabase (mêmes étapes que create-staff-user)
// Chemin attendu : supabase/functions/delete-staff-user/index.ts
// ============================================================
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

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
    if (userErr || !user) {
      return new Response(JSON.stringify({ error: "Non authentifié." }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const { data: profile } = await callerClient
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();

    if (!profile || profile.role !== "superadmin") {
      return new Response(JSON.stringify({ error: "Réservé au superadmin." }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const { userId } = await req.json();
    if (!userId) {
      return new Response(JSON.stringify({ error: "userId requis." }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    if (userId === user.id) {
      return new Response(JSON.stringify({ error: "Tu ne peux pas supprimer ton propre compte." }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const adminClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: targetProfile } = await adminClient.from("profiles").select("is_protected").eq("id", userId).single();
    if (targetProfile?.is_protected) {
      return new Response(JSON.stringify({ error: "Ce compte Admin est protégé et ne peut pas être supprimé." }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    const { error: deleteErr } = await adminClient.auth.admin.deleteUser(userId);
    if (deleteErr) {
      return new Response(JSON.stringify({ error: deleteErr.message }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    // Le profil est supprimé automatiquement (on delete cascade), mais on force au cas où
    await adminClient.from("profiles").delete().eq("id", userId);

    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
  }
});
