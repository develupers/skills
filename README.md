# Develupers Skills

A collection of skills for Claude Code.

## Installation

```
/plugin marketplace add develupers/skills
/plugin install speckit-guide
```

## Available Skills

| Skill                                  | Description                                    |
|----------------------------------------|------------------------------------------------|
| [speckit-guide](plugins/speckit-guide/) | Workflow navigator for Spec-Driven Development |

## Contributing

To add a new skill:

1. Create a folder in `skills/` with your skill name
2. Add a `SKILL.md` file with frontmatter and instructions
3. Include any supporting scripts in a `scripts/` subdirectory

### Skill Structure

```
skills/
└── your-skill/
    ├── SKILL.md          # Required: Skill definition
    ├── README.md         # Optional: Documentation
    └── scripts/          # Optional: Helper scripts
```

### SKILL.md Format

```markdown
Description of when this skill should trigger. Include example phrases users might say.

---

## Skill Title

Instructions for Claude to follow when this skill is activated.
```

## License

MIT
