// Supabase Edge Function: profile
// GET  -> settles streak decay, returns profile + savedCount
// POST { displayName } -> updates display name

import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { adminClient, getUser } from "../_shared/clients.ts";
import { getOrSettleProfile } from "../_shared/streak.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const user = await getUser(req.headers.get("Authorization"));
  if (!user) return errorResponse("Sign in required", 401);

  try {
    const db = adminClient();

    if (req.method === "GET") {
      const profile = await getOrSettleProfile(user.id);
      const { count } = await db
        .from("favorites")
        .select("fact_id", { count: "exact", head: true })
        .eq("user_id", user.id);

      return jsonResponse({ ...profile, saved_count: count ?? 0 });
    }

    if (req.method === "POST") {
      const body = await req.json();
      const displayName = (body?.displayName ?? "").toString().trim().slice(0, 60);
      if (!displayName) return errorResponse("displayName is required", 400);

      const { error } = await db
        .from("profiles")
        .update({ display_name: displayName })
        .eq("id", user.id);
      if (error) throw error;

      return jsonResponse({ ok: true });
    }

    return errorResponse("Method not allowed", 405);
  } catch (e) {
    console.error(e);
    return errorResponse(e instanceof Error ? e.message : "Internal error", 500);
  }
});
