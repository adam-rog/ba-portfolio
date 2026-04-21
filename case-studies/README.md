# Case Studies

End-to-end analytical case studies. Each is a self-contained folder with a consistent structure.

## Naming convention

Folders are numbered and use kebab-case:

```
NN-fictional-domain-topic/
```

Example: `01-newsmo-publishing-process/`, `02-shoply-returns-api/`.

Numbering controls display order on GitHub — lowest number first. Use `01`, `02`, etc. (two digits).

## Structure of a single case study

```
NN-name/
├── README.md              # Full case study narrative
├── assets/                # Images, renders, exports
│   └── *.png
├── *.bpmn / *.puml        # Source files for diagrams
└── *.yaml / *.md          # Other supporting artifacts (OpenAPI, specs, etc.)
```

## Creating a new case study

Copy `_template/` to a new `NN-...` folder and fill in the sections.

Rule of thumb: if a rendered artifact (PNG/SVG) is included, **always** commit its source file alongside it (`.bpmn`, `.puml`, `.drawio`). Recruiters with technical background check this.
