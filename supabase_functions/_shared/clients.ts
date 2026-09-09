import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

/** Bypasses RLS — only for the specific admin operations that need it
 * (picking/generating facts & quiz questions, cross-user streak decay). */
export function adminClient() {
  return createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
  });
}

/** Scoped to whichever user's JWT is in the Authorization header (or the
 * anon role if there isn't one) — every query still goes through RLS. */
export function userClient(authHeader: string | null) {
  return createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: authHeader ? { Authorization: authHeader } : {} },
    auth: { persistSession: false },
  });
}

/** Resolves the signed-in user from the request's Authorization header,
 * or null if the request is anonymous / the token is invalid. */
export async function getUser(authHeader: string | null) {
  if (!authHeader) return null;
  const client = userClient(authHeader);
  const { data, error } = await client.auth.getUser();
  if (error || !data.user) return null;
  return data.user;
}
