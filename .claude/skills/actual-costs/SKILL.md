---
name: actual-costs
description: Report what your Claude Code usage would cost at pay-as-you-go API rates.
argument-hint: [daily|weekly|monthly|session|blocks] [--since YYYYMMDD] [--until YYYYMMDD]
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash(npx:*), Bash(claude auth status:*), WebFetch
---

## Your Task

Report on Claude Code usage costs by running `ccusage` over the local transcript logs, then present a concise, interpreted summary. Frame it as "what this usage would cost on pay-as-you-go API pricing", since the user is on a fixed subscription and wants that comparison.

## Arguments

```
${ARGUMENTS}
```

## Steps

1. Choose the view from the argument. Default to `monthly` when none is given. Valid views: `daily`, `weekly`, `monthly`, `session` (per session), `blocks` (5-hour billing windows).

2. Run ccusage in JSON mode over that view, passing through any `--since` / `--until` (both `YYYYMMDD`):

   ```
   npx -y ccusage@latest <view> --json [--since ... --until ...]
   ```

   For the default overview (no argument), run two commands: `monthly --json` (full history) and `daily --json --last 7` (recent trend).

3. Parse the JSON. `totals.totalCost` is the period cost in USD; each row has `totalCost`, `totalTokens`, and a `modelBreakdowns` array (`modelName`, `cost`, `outputTokens`, `cacheReadTokens`, …).

4. Detect the current subscription so the comparison is grounded in the real plan:

   ```
   claude auth status
   ```

   Read `subscriptionType` from the JSON (`pro`, `max`, `team`, `enterprise`, …).

5. Look up the current price for that plan — do not rely on memory, prices change. Fetch the official pricing page and read off the tier that matches `subscriptionType`:

   ```
   WebFetch https://claude.com/pricing "monthly and annual price per plan: Pro, Max, Team, Enterprise"
   ```

6. Summarize in plain language:
   - Total API-equivalent cost for the period.
   - Which models drove the cost (top entries from `modelBreakdowns`).
   - The recent daily trend when you ran the daily view.
   - The comparison line: API-equivalent cost vs. the detected plan and its current price (from the page you fetched), and roughly how many times the fixed fee the usage is worth. E.g. "Your usage would cost ~$142 on pay-as-you-go API pricing. You're on the Team plan (~$25/seat/mo standard) — that's ~5.7x your seat fee in API-equivalent value."

## Additional Resources

### Subscription Caveats

- `subscriptionType` doesn't distinguish Max 5x from 20x, or Team standard from premium. Quote the range unless the user says which tier.
- `team` and `enterprise` are per-seat, and Team has a multi-seat minimum, so the per-seat figure isn't the org's total bill.
- `enterprise` bills the seat fee plus metered API usage with no included pool.
- If `subscriptionType` is missing or unrecognized, name it as reported and skip the multiplier.
- If the fetch fails, say so and give the comparison qualitatively rather than guessing a number.

