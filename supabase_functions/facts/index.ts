// Supabase Edge Function: facts
// GET ?action=today       -> { fact }               (picks/generates today's fact)
// GET ?action=archive     -> { entries: [...] }      (past facts, newest first)
// GET ?action=by-slug&slug=... -> { fact }|{fact:null}

import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { adminClient } from "../_shared/clients.ts";
import { todayUtc } from "../_shared/date.ts";
import { generateFacts } from "../_shared/gemini.ts";

const POOL_LOW_WATERMARK = 3;
const POOL_TOPUP_BATCH = 5;

async function topUpPoolIfLow(db: ReturnType<typeof adminClient>) {
  const { count } = await db
    .from("facts")
    .select("id", { count: "exact", head: true })
    .is("pick_date", null);

  if ((count ?? 0) >= POOL_LOW_WATERMARK) return;

  const { data: existingTitles } = await db.from("facts").select("title");
  const avoid = (existingTitles ?? []).map((f) => f.title as string);

  const generated = await generateFacts(POOL_TOPUP_BATCH, avoid);
  if (generated.length === 0) return;

  const rows = generated.map((f) => ({
    title: f.title,
    slug: slugify(f.title),
    category: f.category,
    hook: f.hook,
    intro: f.intro,
    steps: f.steps,
    surprising_detail: f.surprising_detail,
  }));
  await db.from("facts").insert(rows);
}

function slugify(title: string): string {
  const base = title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");
  return `${base}-${Math.random().toString(36).slice(2, 7)}`;
}

async function ensureDailyPick(db: ReturnType<typeof adminClient>) {
  const today = todayUtc();

  const { data: existing } = await db
    .from("facts")
    .select("*")
    .eq("pick_date", today)
    .maybeSingle();
  if (existing) return existing;

  await topUpPoolIfLow(db);

  const { data: pool } = await db
    .from("facts")
    .select("*")
    .is("pick_date", null)
    .limit(50);

  if (!pool || pool.length === 0) {
    throw new Error("No facts available and generation failed to produce any.");
  }

  const pick = pool[Math.floor(Math.random() * pool.length)];
  const { data: updated, error } = await db
    .from("facts")
    .update({ pick_date: today })
    .eq("id", pick.id)
    .select("*")
    .single();
  if (error) throw error;
  return updated;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const url = new URL(req.url);
    const action = url.searchParams.get("action") ?? "today";
    const db = adminClient();

    if (action === "today") {
      const fact = await ensureDailyPick(db);
      return jsonResponse({ fact });
    }

    if (action === "archive") {
      const today = todayUtc();
      const { data, error } = await db
        .from("facts")
        .select("*")
        .not("pick_date", "is", null)
        .lt("pick_date", today)
        .order("pick_date", { ascending: false })
        .limit(90);
      if (error) throw error;
      const entries = (data ?? []).map((f) => ({ pick_date: f.pick_date, fact: f }));
      return jsonResponse({ entries });
    }

    if (action === "by-slug") {
      const slug = url.searchParams.get("slug");
      if (!slug) return errorResponse("Missing slug", 400);
      const { data, error } = await db
        .from("facts")
        .select("*")
        .eq("slug", slug)
        .not("pick_date", "is", null)
        .maybeSingle();
      if (error) throw error;
      return jsonResponse({ fact: data ?? null });
    }

    return errorResponse("Unknown action", 400);
  } catch (e) {
    console.error(e);
    return errorResponse(e instanceof Error ? e.message : "Internal error", 500);
  }
});
