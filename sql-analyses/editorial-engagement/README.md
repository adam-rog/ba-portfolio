# Editorial Engagement Analysis — SQL

Analytical SQL queries over an editorial content dataset (digital media domain).
Demonstrates multi-table joins, aggregation, filtering on groups (HAVING),
and awareness of production pitfalls (timestamp ranges, row multiplication in joins).

## Data model

```
articles          id, title, author_id, category, published_at (TIMESTAMP)
authors           id, name, team
article_metrics   article_id, date (DATE), page_views, unique_users, avg_time_s
```

`article_metrics` holds one row per article per day, so any join to it multiplies
article rows — a key consideration in the queries below.

---

## Query 1 — Top 10 articles by page views (July 2026)

**Business question:** Which 10 articles drew the most page views last month?

```sql
SELECT
  a.title,
  SUM(am.page_views) AS pv
FROM articles a
INNER JOIN article_metrics am ON a.id = am.article_id
WHERE am.date BETWEEN '2026-07-01' AND '2026-07-31'
GROUP BY a.id, a.title
ORDER BY pv DESC
LIMIT 10;
```

**Interpretation:** Ranks content by total reach. `GROUP BY a.id, a.title` groups
by the unique key (not just title) so two articles sharing a headline aren't merged.
INNER JOIN is correct here — articles without metrics can't rank anyway.

---

## Query 2 — Most active newsroom authors (July 2026)

**Business question:** Which newsroom authors published more than 5 articles last month?

```sql
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
```

**Interpretation:** Identifies high-output authors for workload and performance
review. Note the date filter uses `>= start AND < next month` rather than
`BETWEEN ... '2026-07-31'` — because `published_at` is a TIMESTAMP, a `BETWEEN`
ending at `'2026-07-31'` (midnight) would silently drop everything published
during the last day. The "> 5" filter is on groups, so it belongs in HAVING, not WHERE.

---

## Query 3 — Category performance (with engagement threshold)

**Business question:** For each category, show article count, total page views and
average time on page — but only categories above 100,000 total PV, ranked by PV.

```sql
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
```

**Interpretation:** Category-level view for editorial strategy — where reach and
engagement concentrate. `COUNT(DISTINCT a.id)` is essential: because
`article_metrics` has one row per article per day, a plain `COUNT` would count
every daily row and massively inflate the article count. `HAVING` filters on the
aggregated SUM (the alias `pv` is repeated as the full expression, since HAVING
executes before SELECT in engines like PostgreSQL/Trino and the alias isn't
available there yet).

---

## Concepts demonstrated

- Multi-table INNER JOIN and choosing INNER vs LEFT deliberately
- Aggregation: `SUM`, `AVG`, `COUNT`, `COUNT(DISTINCT ...)`
- `WHERE` (row filter, pre-grouping) vs `HAVING` (group filter, post-grouping)
- SQL logical execution order and its consequences (alias availability in WHERE/HAVING vs ORDER BY)
- Production pitfalls: timestamp range boundaries, row multiplication in one-to-many joins
