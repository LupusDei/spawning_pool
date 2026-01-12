# Agent Instructions

This project uses **bd** (beads) for issue tracking.

---

## Workflow

**See `.beads/PRIME.md` for the complete mandatory workflow.**

The workflow is automatically loaded at session start. Key points:
- Every change needs a bead
- Always use feature branches (never master)
- Run `bd sync` immediately after claiming a task
- Tests are mandatory
- Quality gates must pass before committing

---

## Project-Specific: Code Quality

### Modularity
- **Design for parallel work**: Each module should be independently testable
- **Minimize cross-module dependencies**: Use clear interfaces between modules
- **One responsibility per file**: Keep files focused and small
- **Avoid tight coupling**: Changes in one module shouldn't break others

### Clean Code Standards
- **TypeScript strict mode**: No `any` types, proper type definitions
- **Consistent naming**: Use clear, descriptive names
- **DRY principle**: Don't repeat yourself - extract common logic
- **Comments**: Only when necessary - code should be self-documenting
- **Error handling**: Handle edge cases gracefully

---

## Project-Specific: Testing

**CRITICAL**: Every feature MUST have tests. Tests are NOT optional.

```bash
npm test                    # Run all tests
npm test -- --watch        # Run tests in watch mode
npm test -- --coverage     # Check code coverage
```

**Testing Guidelines:**
- Write tests BEFORE or ALONGSIDE implementation
- Aim for high coverage (>80%) on critical code
- Test edge cases and error conditions
- Unit tests for pure functions and utilities
- Integration tests for component interactions
- Keep tests fast and independent

**Test Organization:**
```
src/
├── components/
│   ├── Button.tsx
│   └── Button.test.tsx
├── engine/
│   ├── physics.ts
│   └── physics.test.ts
└── utils/
    ├── math.ts
    └── math.test.ts
```

---

## Project-Specific: Quality Gates

Before committing, ALL must pass:
```bash
npm run build     # TypeScript compilation
npm run lint      # Code quality
npm test          # Test suite
```
