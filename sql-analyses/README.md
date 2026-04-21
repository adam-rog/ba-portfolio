# SQL Analyses

Data analyses with business interpretation. Each analysis is a folder containing:

```
topic-name/
├── README.md       # Context, question, findings, business recommendation
├── queries.sql     # The actual SQL
└── findings.md     # Optional: deeper interpretation or extra charts
```

Rule: **always pair SQL with business narrative.** A `.sql` file alone is a developer artifact. The business interpretation is what makes this a BA artifact.

Use public / synthetic data (Kaggle, generated samples). Never commit data that could be traced to real users or organizations.
