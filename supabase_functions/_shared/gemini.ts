const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!;
const MODEL = "gemini-2.0-flash";
const ENDPOINT =
  `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}`;

async function callGemini(prompt: string, schema: Record<string, unknown>) {
  const res = await fetch(ENDPOINT, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ role: "user", parts: [{ text: prompt }] }],
      generationConfig: {
        temperature: 0.9,
        responseMimeType: "application/json",
        responseSchema: schema,
      },
    }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Gemini request failed (${res.status}): ${body}`);
  }
  const data = await res.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) throw new Error("Gemini returned no content");
  return JSON.parse(text);
}

const FACT_SCHEMA = {
  type: "OBJECT",
  properties: {
    title: { type: "STRING" },
    category: { type: "STRING" },
    hook: { type: "STRING" },
    intro: { type: "STRING" },
    steps: { type: "ARRAY", items: { type: "STRING" } },
    surprising_detail: { type: "STRING" },
  },
  required: ["title", "category", "hook", "intro", "steps", "surprising_detail"],
};

export interface GeneratedFact {
  title: string;
  category: string;
  hook: string;
  intro: string;
  steps: string[];
  surprising_detail: string;
}

export async function generateFacts(
  count: number,
  avoidTitles: string[],
): Promise<GeneratedFact[]> {
  const prompt = `You write short, delightful "how things work" daily-fact cards for a
curiosity app called The Daily How. Generate ${count} completely distinct facts.

Each fact needs:
- title: a punchy, specific title (not generic), under 60 characters
- category: one short category word/phrase (e.g. "Science", "History", "Nature", "Technology", "Food", "Space", "Human Body")
- hook: one enticing sentence that makes someone want to read more
- intro: 2-3 sentences setting up the topic
- steps: 3-5 short strings, each explaining one step of how the thing works, in order
- surprising_detail: one genuinely surprising or delightful closing detail

Avoid these existing titles entirely: ${avoidTitles.join(", ") || "(none yet)"}.
Return strictly matching the JSON schema, as an array under "facts".`;

  const result = await callGemini(prompt, {
    type: "OBJECT",
    properties: { facts: { type: "ARRAY", items: FACT_SCHEMA } },
    required: ["facts"],
  });
  return result.facts as GeneratedFact[];
}

const QUESTION_SCHEMA = {
  type: "OBJECT",
  properties: {
    prompt: { type: "STRING" },
    options: { type: "ARRAY", items: { type: "STRING" } },
    correct_index: { type: "INTEGER" },
    explanation: { type: "STRING" },
  },
  required: ["prompt", "options", "correct_index", "explanation"],
};

export interface GeneratedQuestion {
  prompt: string;
  options: string[];
  correct_index: number;
  explanation: string;
}

export async function generateQuizQuestion(fact: {
  title: string;
  intro: string;
  steps: string[];
  surprising_detail: string;
}): Promise<GeneratedQuestion> {
  const prompt = `Based on this fact card, write one multiple-choice recall question
to quiz someone who read it yesterday.

Title: ${fact.title}
Intro: ${fact.intro}
Steps: ${fact.steps.join(" | ")}
Surprising detail: ${fact.surprising_detail}

Requirements:
- prompt: a clear question testing recall of a specific detail (not too easy, not a trick question)
- options: exactly 4 plausible answers, only one correct
- correct_index: 0-based index of the correct option
- explanation: 1-2 sentences explaining why the correct answer is right

Return strictly matching the JSON schema.`;

  return (await callGemini(prompt, QUESTION_SCHEMA)) as GeneratedQuestion;
}
