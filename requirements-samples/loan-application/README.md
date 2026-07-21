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

## 5. Acceptance Criteria (sample)

Acceptance criteria are shown for two representative stories: one driven by a
business rule (Story 5) and one unhappy path (Story 9). Format: Given / When / Then.

### Story 5 — credit score decision

```
Scenario 1: Low-risk application is auto-approved
  Given a submitted application with all required data
  When the credit score is calculated and is >= 80
  Then the application is marked as low-risk
  And it is approved automatically

Scenario 2: Borderline application goes to manual review
  Given a submitted application with all required data
  When the credit score is calculated and is below 80
  Then the application is marked for manual review
  And it is routed to a credit risk analyst
```

### Story 9 — input validation

```
Scenario: Invalid data blocks submission
  Given I am a customer filling in the loan application form
  When I enter a PESEL number that is too short
  Then the system displays a validation error
  And the form cannot be submitted until it is corrected
```

---

## Skills demonstrated

Requirements elicitation (technique selection by context) · user story writing
(INVEST) · epic decomposition (vertical slicing by workflow / happy-unhappy path /
role) · acceptance criteria (Given/When/Then) · working in a regulated,
multi-stakeholder fintech domain (KYC, AML, credit risk).
