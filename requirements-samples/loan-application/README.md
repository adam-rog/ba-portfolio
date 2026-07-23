# Online Loan Application — From Business Need to Backlog

A requirements sample demonstrating the full BA chain for a fintech scenario:
business context → elicitation approach → epic → user stories (vertical, INVEST)
→ acceptance criteria. The domain (online lending) is deliberately outside my
day-to-day work, to show analysis in a regulated, multi-stakeholder domain.

---

## 1. Context & Business Need

A lending institution wants to offer cash loans through a fully online
application, replacing branch-based, paper-heavy processing. Digital origination
reduces operational cost, removes dependency on branch staff, and widens reach —
customers can apply anytime, and a fast decision is a key competitive edge
against other fintechs.

The core tension shapes the whole process: the business wants to **maximise
approved loans** (more loans → more interest income), but every loan carries
**credit risk** (non-repayment) and **regulatory risk** (money laundering,
identity fraud). Criteria too loose raise conversion but also defaults and
compliance exposure; criteria too strict reduce losses but reject good customers.
The system must balance **speed and conversion** against **risk and compliance**.

**Stakeholders**

- Loan applicant — submits the application
- Credit risk analyst — assesses borderline cases
- Compliance / AML officer — KYC and anti-money-laundering obligations
- Legal — loan agreements, consumer credit law
- The lender / business — revenue and risk appetite
- External: credit bureau (BIK), scoring system, and the regulator (KNF)
  whose requirements constrain the process

**Measurable value:** application conversion rate (started → approved),
decision time, default rate, and fraud rate. Success means high conversion
*at an acceptable level of risk* — not conversion alone.

---

## 2. Elicitation Approach

Requirements come from two distinct sources — stakeholder needs and regulatory
constraints — so techniques were chosen accordingly:

- **Document analysis** — for regulatory requirements (KYC, AML, consumer credit
  law, KNF guidelines). These are codified in law and internal compliance
  procedures, not elicited from stakeholders; findings are validated with the
  compliance officer, since legal text still needs interpretation into system rules.
- **Workshops** — to reconcile conflicting stakeholder goals (business maximising
  conversion vs. risk/compliance minimising exposure). A joint session surfaces
  the tension and forces an explicit, business-owned decision rather than two
  contradictory requirement sets.
- **Interviews** — with the credit risk analyst, to extract deep individual
  expertise on scoring logic and decision rules.
- **Observation (shadowing)** — to capture tacit knowledge: experienced analysts
  assess applications partly on intuition they can't fully articulate. Watching
  real assessments reveals rules that interviews miss.
- **Competitor analysis** — reviewing existing lending flows as a benchmark for
  UX and feature expectations in a competitive market.

---

## 3. Epic

> **As a customer, I want to apply for a cash loan entirely online, so that I get
> a fast decision without paperwork or a branch visit.**

Too large for a single sprint, so it is split into the stories below.

---

## 4. User Stories

Split by workflow (steps of the process), happy/unhappy paths, and stakeholder
role. Each story is a vertical slice — it delivers a working, demonstrable piece
end-to-end, rather than a technical layer.

1. As a customer, I want to start a loan application by entering my personal
   details, so that I can begin the process online.

2. As a customer, I want to verify my identity, so that the lender can confirm
   who I am (KYC requirement).

3. As a customer, I want to provide my income and employment details, so that
   the lender can assess whether I can afford the loan.

4. As a risk analyst, I want the system to automatically retrieve the applicant's
   credit history from BIK, so that I get a quick view of their creditworthiness.

5. As a risk analyst, I want the system to calculate a credit score, so that
   low-risk applications are approved automatically.

6. As a credit risk analyst, I want to review borderline applications, so that
   these cases get a proper human decision.

7. As a customer, I want to receive the loan decision, so that I know whether I
   was approved and on what terms.

8. As a customer, I want to see the reason for a rejection, so that I understand
   why my application was declined (as required by consumer credit regulations).

9. As a customer, I want to be notified when I enter invalid details, so that I
   can correct them before submitting.

10. As a compliance officer, I want the system to flag applications matching AML
    risk criteria, so that suspicious cases are reviewed before approval.

---

## 5. Acceptance Criteria

Full acceptance criteria for Story 5 (the scoring decision), covering the happy
path, the alternative path, boundary conditions, and error cases. Format:
Given / When / Then. Business rule: **credit score >= 80 → auto-approve;
below 80 → manual review.**

### Story 5 — automatic scoring decision

```gherkin
# HAPPY PATH — auto-approval
Scenario: High score is auto-approved
  Given a submitted application with all required data
  When the credit score is calculated and is above 80
  Then the application is marked as low-risk
  And it is approved automatically

# BOUNDARY — exactly at the threshold
Scenario: Score exactly at the threshold is approved
  Given a submitted application with all required data
  When the credit score is exactly 80
  Then the application is approved automatically
  # (rule is ">= 80", so 80 must pass — this pins down >= vs >)

# BOUNDARY — just below the threshold
Scenario: Score just below the threshold goes to review
  Given a submitted application with all required data
  When the credit score is exactly 79
  Then the application is sent to manual review
  And it is not approved automatically

# ALTERNATIVE PATH — manual review
Scenario: Below-threshold score is routed to an analyst
  Given a submitted application with all required data
  When the credit score is below 80
  Then the application is marked for manual review
  And it is routed to a credit risk analyst

# ERROR CASE — score unavailable
Scenario: Missing credit score blocks the decision
  Given a submitted application for which no credit score could be calculated
  When the automatic decision step runs
  Then the application is not auto-approved
  And it is routed to manual review with a flag "score unavailable"
```

### Story 9 — input validation (error case)

```gherkin
Scenario: Invalid PESEL blocks submission
  Given I am a customer filling in the loan application form
  When I enter a PESEL number that is too short
  Then the system displays a validation error
  And the form cannot be submitted until it is corrected
```

*Note on boundary testing:* for any rule with a limit (age >= 18, amount in
1000–50000, score >= 80), the criteria test **both sides of each boundary** —
e.g. score 79 (review) and 80 (approve) — because that is where off-by-one
errors (`<` vs `<=`) hide, not in the middle of the range.

---

## Skills demonstrated

Requirements elicitation (technique selection by context) · user story writing
(INVEST) · epic decomposition (vertical slicing by workflow / happy-unhappy path /
role) · acceptance criteria (Given/When/Then) · working in a regulated,
multi-stakeholder fintech domain (KYC, AML, credit risk).
