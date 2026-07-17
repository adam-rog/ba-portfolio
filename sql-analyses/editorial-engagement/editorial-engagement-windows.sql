-- Editorial Engagement Analysis — Window Functions layer
-- Builds on the base analysis with ranking, running totals and period-over-period comparison.
-- Data model:
--   articles(id, title, author_id, category, published_at TIMESTAMP)
--   authors(id, name, team)
--   article_metrics(article_id, date DATE, page_views, unique_users, avg_time_s)

-- Query 1 — Top 3 most-read articles per category (ROW_NUMBER)
-- Window function is filtered via a subquery, since it can't be referenced in WHERE.
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

-- Query 2 — Cumulative page views over time for one article (running total)
-- SUM(...) OVER (ORDER BY date) accumulates from the first row up to the current one.
-- No GROUP BY: a window function keeps every row.
SELECT
  article_id,
  date,
  page_views,
  SUM(page_views) OVER (ORDER BY date) AS cumulative_pv
FROM article_metrics
WHERE article_id = 42
ORDER BY date;

-- Query 3 — Monthly PV with month-over-month change (LAG)
-- Inner query aggregates PV per month; outer query uses LAG to reach the previous month.
-- First month has NULL prev_pv (no earlier row), so its change is NULL.
SELECT
  month,
  monthly_pv,
  LAG(monthly_pv) OVER (ORDER BY month) AS prev_pv,
  monthly_pv - LAG(monthly_pv) OVER (ORDER BY month) AS change_mom
FROM (
    SELECT
      DATE_TRUNC('month', date) AS month,
      SUM(page_views) AS monthly_pv
    FROM article_metrics
    GROUP BY DATE_TRUNC('month', date)
) monthly
ORDER BY month;
