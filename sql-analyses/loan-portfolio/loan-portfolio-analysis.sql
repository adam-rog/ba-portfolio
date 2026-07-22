-- Loan Portfolio Analysis
-- Fintech domain. Data model (aligned with the Loan Application API):
--   applications(id, customer_id, loan_amount, monthly_income, status,
--                credit_score, defaulted, created_at)
--   status in ('pending','review','approved','rejected','cancelled')
--   defaulted: boolean, applies to approved loans (did the borrower fail to repay)

-- Query 1 — Application conversion by status
-- Share of applications in each status (approval funnel).
SELECT
  status,
  COUNT(*) AS application_count,
  COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS pct_of_total
FROM applications
GROUP BY status
ORDER BY application_count DESC;

-- Query 2 — Default rate by loan amount bucket
-- Does risk (non-repayment) rise with loan size? Only approved loans can default.
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

-- Query 3 — Decision distribution by credit score band
-- Does the credit score actually translate into decisions?
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
