// Supabase Edge Function: quiz
// GET  ?action=daily                                 -> { quiz }|{quiz:null}
// GET  ?action=question&factId=&questionIndex=        -> { question }|{question:null}
// POST ?action=answer  { factId, questionIndex, selectedIndex } -> grade (+ persist/reward if signed in)
// GET  ?action=attempt&factId=          (auth)        -> { attempt }|{attempt:null}
// GET  ?action=calendar&month=YYYY-MM   (auth)        -> { correct: string[], saved: string[] }
// GET  ?action=stats                     (auth)       -> { total_answered, total_correct, accuracy }

import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { adminClient, getUser } from "../_shared/clients.ts";
import { todayUtc, yesterdayUtc } from "../_shared/date.ts";
import { generateQuizQuestion } from "../_shared/gemini.ts";
import { applyQuizReward } from "../_shared/streak.ts";

const BONUS_QUESTION_COINS = 3;

async function getOrGenerateQuestion(
  db: ReturnType<typeof adminClient>,
  factId: string,
  questionIndex: number,
) {
  const { data: existing } = await db
    .from("quiz_questions")
    .select("*")
    .eq("fact_id", factId)
    .eq("question_index", questionIndex)
    .maybeSingle();
  if (existing) return existing;

  const { data: fact, error: factErr } = await db
    .from("facts")
    .select("title, intro, steps, surprising_detail")
    .eq("id", factId)
    .single();
  if (factErr) throw factErr;

  const generated = await generateQuizQuestion(fact);
  const { data: inserted, error } = await db
    .from("quiz_questions")
    .insert({
      fact_id: factId,
      question_index: questionIndex,
      prompt: generated.prompt,
      options: generated.options,
      correct_index: generated.correct_index,
      explanation: generated.explanation,
    })
    .select("*")
    .single();
  if (error) throw error;
  return inserted;
}

function publicQuestion(q: Record<string, unknown>) {
  return {
    id: q.id,
    question_index: q.question_index,
    prompt: q.prompt,
    options: q.options,
  };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const url = new URL(req.url);
    const action = url.searchParams.get("action") ?? "daily";
    const db = adminClient();

    if (action === "daily" && req.method === "GET") {
      const yesterday = yesterdayUtc();
      const { data: fact } = await db
        .from("facts")
        .select("id, title")
        .eq("pick_date", yesterday)
        .maybeSingle();
      if (!fact) return jsonResponse({ quiz: null });

      const question = await getOrGenerateQuestion(db, fact.id, 0);
      return jsonResponse({
        quiz: { fact_id: fact.id, fact_title: fact.title, question: publicQuestion(question) },
      });
    }

    if (action === "question" && req.method === "GET") {
      const factId = url.searchParams.get("factId");
      const questionIndex = Number(url.searchParams.get("questionIndex") ?? "0");
      if (!factId) return errorResponse("Missing factId", 400);
      const question = await getOrGenerateQuestion(db, factId, questionIndex);
      return jsonResponse({ question: publicQuestion(question) });
    }

    if (action === "answer" && req.method === "POST") {
      const body = await req.json();
      const factId = body?.factId as string;
      const questionIndex = Number(body?.questionIndex ?? 0);
      const selectedIndex = Number(body?.selectedIndex);
      if (!factId || Number.isNaN(selectedIndex)) return errorResponse("Missing factId/selectedIndex", 400);

      const { data: question, error: qErr } = await db
        .from("quiz_questions")
        .select("*")
        .eq("fact_id", factId)
        .eq("question_index", questionIndex)
        .single();
      if (qErr) throw qErr;

      const isCorrect = selectedIndex === question.correct_index;
      const user = await getUser(req.headers.get("Authorization"));

      if (!user) {
        // Anonymous: grade only, nothing persisted, no rewards.
        return jsonResponse({
          is_correct: isCorrect,
          correct_index: question.correct_index,
          explanation: question.explanation,
        });
      }

      const today = todayUtc();
      const { data: existingAttempt } = await db
        .from("quiz_attempts")
        .select("*")
        .eq("user_id", user.id)
        .eq("fact_id", factId)
        .eq("question_index", questionIndex)
        .maybeSingle();

      if (existingAttempt) {
        // Idempotent: already answered, don't re-award.
        return jsonResponse({
          is_correct: existingAttempt.is_correct,
          correct_index: question.correct_index,
          explanation: question.explanation,
          coins_awarded: 0,
        });
      }

      await db.from("quiz_attempts").insert({
        user_id: user.id,
        quiz_date: today,
        fact_id: factId,
        question_index: questionIndex,
        selected_index: selectedIndex,
        is_correct: isCorrect,
      });

      let coinsAwarded = 0;
      let newStreak: number | undefined;

      if (questionIndex === 0) {
        const reward = await applyQuizReward(user.id, isCorrect);
        coinsAwarded = reward.coinsAwarded;
        newStreak = reward.newStreak;
      } else if (isCorrect) {
        coinsAwarded = BONUS_QUESTION_COINS;
        const { data: profile } = await db
          .from("profiles")
          .select("coins")
          .eq("id", user.id)
          .single();
        await db
          .from("profiles")
          .update({ coins: (profile?.coins ?? 0) + coinsAwarded })
          .eq("id", user.id);
      }

      return jsonResponse({
        is_correct: isCorrect,
        correct_index: question.correct_index,
        explanation: question.explanation,
        coins_awarded: coinsAwarded,
        new_streak: newStreak,
      });
    }

    // Everything below requires auth.
    const user = await getUser(req.headers.get("Authorization"));
    if (!user) return errorResponse("Sign in required", 401);

    if (action === "attempt" && req.method === "GET") {
      const factId = url.searchParams.get("factId");
      if (!factId) return errorResponse("Missing factId", 400);

      const { data: attempt } = await db
        .from("quiz_attempts")
        .select("*")
        .eq("user_id", user.id)
        .eq("fact_id", factId)
        .eq("question_index", 0)
        .maybeSingle();

      if (!attempt) return jsonResponse({ attempt: null });

      const { data: question } = await db
        .from("quiz_questions")
        .select("correct_index, explanation")
        .eq("fact_id", factId)
        .eq("question_index", 0)
        .single();

      return jsonResponse({
        attempt: {
          is_correct: attempt.is_correct,
          correct_index: question?.correct_index,
          explanation: question?.explanation,
        },
      });
    }

    if (action === "calendar" && req.method === "GET") {
      const month = url.searchParams.get("month"); // YYYY-MM
      if (!month) return errorResponse("Missing month", 400);
      const start = `${month}-01`;
      const [y, m] = month.split("-").map(Number);
      const nextMonth = new Date(Date.UTC(y, m, 1)).toISOString().slice(0, 10);

      const { data: correctRows } = await db
        .from("quiz_attempts")
        .select("quiz_date")
        .eq("user_id", user.id)
        .eq("is_correct", true)
        .gte("quiz_date", start)
        .lt("quiz_date", nextMonth);

      const { data: savedRows } = await db
        .from("favorites")
        .select("created_at")
        .eq("user_id", user.id)
        .gte("created_at", start)
        .lt("created_at", nextMonth);

      const correct = [...new Set((correctRows ?? []).map((r) => r.quiz_date as string))];
      const saved = [
        ...new Set((savedRows ?? []).map((r) => (r.created_at as string).slice(0, 10))),
      ];

      return jsonResponse({ correct, saved });
    }

    if (action === "stats" && req.method === "GET") {
      const { count: totalAnswered } = await db
        .from("quiz_attempts")
        .select("id", { count: "exact", head: true })
        .eq("user_id", user.id);
      const { count: totalCorrect } = await db
        .from("quiz_attempts")
        .select("id", { count: "exact", head: true })
        .eq("user_id", user.id)
        .eq("is_correct", true);

      const answered = totalAnswered ?? 0;
      const correct = totalCorrect ?? 0;
      return jsonResponse({
        total_answered: answered,
        total_correct: correct,
        accuracy: answered > 0 ? Math.round((correct / answered) * 100) : 0,
      });
    }

    return errorResponse("Unknown action", 400);
  } catch (e) {
    console.error(e);
    return errorResponse(e instanceof Error ? e.message : "Internal error", 500);
  }
});
