/** YYYY-MM-DD for "now", in UTC. Facts flip at UTC midnight; simple and
 * predictable across all users (per-user timezone support can be layered
 * on top of `profiles.timezone` later if you need it). */
export function todayUtc(): string {
  return new Date().toISOString().slice(0, 10);
}

export function addDays(dateStr: string, days: number): string {
  const d = new Date(dateStr + "T00:00:00Z");
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}

export function yesterdayUtc(): string {
  return addDays(todayUtc(), -1);
}
