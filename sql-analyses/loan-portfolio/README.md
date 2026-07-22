# Loan Portfolio Analysis — SQL

Analytical SQL over a loan application dataset, answering risk and conversion
questions a lending business would actually ask. Same domain and data model as
the Loan Application API in this case study.

## Data model

```
applications(id, customer_id, loan_amount, monthly_income, status,
             credit_score, defaulted, created_at)
  status   : pending | review | approved | rejected | cancelled
  defaulted: boolean — applies to approved loans (borrower failed to repay)
```

---

## Query 1 — Application conversion by status

**Business question:** What share of applications ends up approved, rejected, or still in progress?

```sql
SELECT
  status,
  COUNT(*) AS application_count,
  COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS pct_of_total
FROM applications
GROUP BY status
ORDER BY application_count DESC;
```

**Why this design:** The approval funnel is a core business metric. The percentage
combines an aggregate with a window function — `SUM(COUNT(*)) OVER ()` is the grand
total across all groups, so each status's share is `count / total`. `* 100.0`
(not `100`) forces decimal division instead of integer rounding.

---

## Query 2 — Default rate by loan amount

**Business question:** Do larger loans default more often? (Risk vs loan size.)

```sql
SELECT
  CASE
    WHEN loan_amount < 5000  THEN 'small'
    WHEN loan_amount < 20000 THEN 'medium'
    ELSE 'large'
  END AS amount_bucket,
  SUM(CASE WHEN defaulted THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS default_rate
FROM applications
WHERE status = 'approved'
GROUP BY
  CASE
    WHEN loan_amount < 5000  THEN 'small'
    WHEN loan_amount < 20000 THEN 'medium'
    ELSE 'large'
  END
ORDER BY default_rate DESC;
```

**Why this design:** `CASE` buckets a continuous value (amount) into risk segments.
The default rate is conditional aggregation — `SUM(CASE WHEN defaulted THEN 1 ELSE 0 END)`
counts only defaults, divided by the segment total. Filtered to approved loans,
since only disbursed loans can default. The `CASE` is repeated in `GROUP BY` (not
referenced by alias) because `SELECT` aliases aren't available at grouping time.

---

## Query 3 — Decision distribution by credit score band

**Business question:** Does the credit score actually drive decisions — do higher scores get approved more?

```sql
SELECT
  CASE
    WHEN credit_score < 550               THEN '<550'
    WHEN credit_score BETWEEN 550 AND 599 THEN '550-599'
    WHEN credit_score BETWEEN 600 AND 649 THEN '600-649'
    WHEN credit_score BETWEEN 650 AND 699 THEN '650-699'
    WHEN credit_score BETWEEN 700 AND 749 THEN '700-749'
    WHEN credit_score >= 750              THEN '750+'
  END AS credit_score_range,
  status,
  COUNT(*) AS application_count
FROM applications
GROUP BY
  CASE
    WHEN credit_score < 550               THEN '<550'
    WHEN credit_score BETWEEN 550 AND 599 THEN '550-599'
    WHEN credit_score BETWEEN 600 AND 649 THEN '600-649'
    WHEN credit_score BETWEEN 650 AND 699 THEN '650-699'
    WHEN credit_score BETWEEN 700 AND 749 THEN '700-749'
    WHEN credit_score >= 750              THEN '750+'
  END,
  status
ORDER BY
  CASE
    WHEN credit_score < 550               THEN 1
    WHEN credit_score BETWEEN 550 AND 599 THEN 2
    WHEN credit_score BETWEEN 600 AND 649 THEN 3
    WHEN credit_score BETWEEN 650 AND 699 THEN 4
    WHEN credit_score BETWEEN 700 AND 749 THEN 5
    ELSE 6
  END,
  status;
```

**Why this design:** Cross-tabulates score band against decision to validate that
scoring correlates with outcomes. Note the `ORDER BY` uses a separate `CASE` that
maps bands to 1–6: sorting by the label alphabetically would misorder them
('<550' and numeric strings don't sort naturally), so an explicit ordinal keeps
the bands in logical sequence.

---

## Concepts demonstrated

Conditional aggregation (`SUM(CASE WHEN ...)`) · bucketing continuous values with
`CASE` · percentage-of-total via window function (`SUM(COUNT(*)) OVER ()`) ·
multi-dimensional grouping · custom sort ordering · translating risk/conversion
questions into SQL.
