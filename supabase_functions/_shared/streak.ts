import { adminClient } from "./clients.ts";
import { addDays, todayUtc, yesterdayUtc } from "./date.ts";

export interface ProfileRow {
  id: string;
  display_name: string | null;
  streak_count: number;
  longest_streak: number;
  coins: number;
  last_seen_date: string | null;
  saved_days: string[] | null;
}

/** Fetches (or creates) a user's profile row, then breaks the streak if
 * they missed a day. Does NOT increment the streak — that only happens
 * when they actually answer today's question, in `applyQuizReward`. */
export async function getOrSettleProfile(userId: string): Promise<ProfileRow> {
  const db = adminClient();
  const today = todayUtc();
  const yesterday = yesterdayUtc();

  let { data: profile } = await db
    .from("profiles")
    .select("*")
    .eq("id", userId)
    .maybeSingle();

  if (!profile) {
    const { data: created, error } = await db
      .from("profiles")
      .insert({ id: userId, streak_count: 0, longest_streak: 0, coins: 0 })
      .select("*")
      .single();
    if (error) throw error;
    profile = created;
  }

  const lastSeen = profile.last_seen_date as string | null;
  const streakBroken = lastSeen !== null && lastSeen !== today && lastSeen !== yesterday;

  if (streakBroken && profile.streak_count !== 0) {
    const { data: updated, error } = await db
      .from("profiles")
      .update({ streak_count: 0 })
      .eq("id", userId)
      .select("*")
      .single();
    if (error) throw error;
    profile = updated;
  }

  return profile as ProfileRow;
}

const CORRECT_COINS = 10;
const PARTICIPATION_COINS = 2;

/** Called once per user per day, the first time they answer the daily
 * (question_index 0) question. Awards coins and advances the streak. */
export async function applyQuizReward(userId: string, isCorrect: boolean) {
  const db = adminClient();
  const today = todayUtc();
  const yesterday = yesterdayUtc();

  const profile = await getOrSettleProfile(userId);
  if (profile.last_seen_date === today) {
    // Already settled today (shouldn't normally happen — caller checks
    // quiz_attempts first — but stay idempotent just in case).
    return { coinsAwarded: 0, newStreak: profile.streak_count };
  }

  const newStreak = profile.last_seen_date === yesterday ? profile.streak_count + 1 : 1;
  const coinsAwarded = isCorrect ? CORRECT_COINS : PARTICIPATION_COINS;

  const { data: updated, error } = await db
    .from("profiles")
    .update({
      streak_count: newStreak,
      longest_streak: Math.max(newStreak, profile.longest_streak),
      coins: profile.coins + coinsAwarded,
      last_seen_date: today,
    })
    .eq("id", userId)
    .select("*")
    .single();
  if (error) throw error;

  return { coinsAwarded, newStreak: updated.streak_count };
}

export { addDays };
