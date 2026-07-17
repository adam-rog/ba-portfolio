# Editorial Engagement Analysis — Window Functions

Advanced SQL layer extending the base engagement analysis with **window functions**:
ranking within groups, running totals, and period-over-period comparison. Same
digital-media data model as the base analysis.

## Data model

```
articles          id, title, author_id, category, published_at (TIMESTAMP)
authors           id, name, team
article_metrics   article_id, date (DATE), page_views, unique_users, avg_time_s
```

---

## Query 1 — Top 3 articles per category

**Business question:** What are the 3 most-read articles in each category?

```sql
SELECT category, title, pv, rn
FROM (
    SELECT
      a.category,
      a.title,
      SUM(am.page_views) AS pv,
      ROW_NUMBER() OVER (
        PARTITION BY a.category
        ORDER BY SUM(am.page_views) DESC
      ) AS rn
    FROM articles a
    LEFT JOIN article_metrics am ON a.id = am.article_id
    GROUP BY a.category, a.title
) ranked
WHERE rn <= 3
ORDER BY category, rn;
```

**Why this design:** A plain `ORDER BY ... LIMIT 3` returns only the global top 3.
`ROW_NUMBER() OVER (PARTITION BY category ...)` restarts the ranking inside each
category, so filtering `rn <= 3` yields three per category. The window function
is filtered in an outer query because it can't be referenced in `WHERE` — window
functions are evaluated after `WHERE` in SQL's logical execution order.

---

## Query 2 — Cumulative page views (running total)

**Business question:** How does one article accumulate views day by day?

```sql
SELECT
  article_id,
  date,
  page_views,
  SUM(page_views) OVER (ORDER BY date) AS cumulative_pv
FROM article_metrics
WHERE article_id = 42
ORDER BY date;
```

**Why this design:** Adding `ORDER BY date` inside `OVER()` turns a total into a
running total — it sums from the first row up to the current one, rather than the
whole partition at once. No `GROUP BY` is used: a window function keeps every row,
so each day stays visible alongside its cumulative figure.

---

## Query 3 — Month-over-month PV change (LAG)

**Business question:** How did total monthly page views change versus the previous month?

```sql
SELECT
  month,
  monthly_pv,
  LAG(monthly_pv) OVER (ORDER BY month)              AS prev_pv,
  monthly_pv - LAG(monthly_pv) OVER (ORDER BY month) AS change_mom
FROM (
    SELECT
      DATE_TRUNC('month', date) AS month,
      SUM(page_views) AS monthly_pv
    FROM article_metrics
    GROUP BY DATE_TRUNC('month', date)
) monthly
ORDER BY month;
```

**Why this design:** The inner query aggregates PV per month; the outer query uses
`LAG` to pull the previous month's value onto the same row, making the delta a
simple subtraction. The subquery is required because `LAG` must operate on the
already-aggregated monthly rows — those rows don't exist until the `GROUP BY`
completes. The earliest month has `NULL` for `prev_pv` (no prior row), so its
`change_mom` is `NULL` — correct, since there is nothing to compare against.

---

## Concepts demonstrated

- `ROW_NUMBER`, `RANK`, `DENSE_RANK` and their tie behaviour
- `PARTITION BY` (independent ranking per group) vs unpartitioned windows
- `ORDER BY` inside `OVER()` changing the result (running total, ranking order)
- `LAG` / `LEAD` for period-over-period comparison, with NULL at window edges
- Filtering window results via a subquery (execution-order constraint)
- Combining `GROUP BY` aggregation with window functions across two query levels
