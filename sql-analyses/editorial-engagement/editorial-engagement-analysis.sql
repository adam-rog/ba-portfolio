-- Editorial Engagement Analysis
-- Digital media domain. Data model:
--   articles(id, title, author_id, category, published_at TIMESTAMP)
--   authors(id, name, team)
--   article_metrics(article_id, date DATE, page_views, unique_users, avg_time_s)
-- Note: article_metrics has one row per article per day.

-- Query 1 — Top 10 articles by page views (July 2026)
SELECT
  a.title,
  SUM(am.page_views) AS pv
FROM articles a
INNER JOIN article_metrics am ON a.id = am.article_id
WHERE am.date BETWEEN '2026-07-01' AND '2026-07-31'
GROUP BY a.id, a.title
ORDER BY pv DESC
LIMIT 10;

-- Query 2 — Newsroom authors with more than 5 articles (July 2026)
-- Date filter uses >= / < to safely cover a TIMESTAMP column.
SELECT
  aut.name,
  COUNT(a.id) AS article_count
FROM articles a
INNER JOIN authors aut ON a.author_id = aut.id
WHERE a.published_at >= '2026-07-01'
  AND a.published_at <  '2026-08-01'
  AND aut.team = 'newsroom'
GROUP BY aut.name
HAVING COUNT(a.id) > 5
ORDER BY article_count DESC;

-- Query 3 — Category performance with engagement threshold
-- COUNT(DISTINCT a.id) because the join to daily metrics multiplies article rows.
SELECT
  a.category,
  COUNT(DISTINCT a.id) AS article_count,
  SUM(am.page_views)   AS pv,
  AVG(am.avg_time_s)   AS avg_time_s
FROM articles a
INNER JOIN article_metrics am ON a.id = am.article_id
GROUP BY a.category
HAVING SUM(am.page_views) > 100000
ORDER BY pv DESC;
