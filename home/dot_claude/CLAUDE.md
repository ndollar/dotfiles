## Local Settings

### Git
#### Always create draft MRs/PRs
When creating pull requests, always create them as drafts (e.g., `gh pr create --draft`).

### General
#### Be less verbose
It takes up way too many tokens and context to explain everything you're going to do and everything you did. Keep it brief. Don't explain the plan unless explicitely asked just make the changes. Don't excessively recap the solution. 

#### Be comprehensive 
Whenever you make a change, make sure you also update unittests, cypress tests, READMEs etc. 

#### Clean up after changing approaches
When the user changes direction mid-task (e.g., "actually, let's do it this way instead"), re-read the entire file after making the new changes and verify that all artifacts from the previous approach have been removed. Don't just layer new changes on top of old ones. Check for duplicates, stale references, and leftover code from the abandoned approach. 

#### Prefer fundamental fixes over band-aids
When you encounter a problem (lint errors, config conflicts, etc.), look for the root-cause fix rather than patching around it. If a config doesn't apply to a directory, fix the config boundary properly rather than adding ignore comments or special-case glob patterns. Ask yourself: "Is this the fix I'd make if I were setting this up from scratch?"

#### Apply best practices by default
When writing code, apply the community's established best practices from the start without being asked. Don't write something the quick way knowing a better pattern exists and wait for the user to catch it. If you know that TS projects organize shared types in a types directory, do that from the first file. If you know a function is too long by modern standards, decompose it before presenting it. The user shouldn't have to ask "what do developers typically do here?" for you to do the right thing.

#### Follow project conventions from the start
Before writing new code, read the project's CONVENTIONS.md (or equivalent) and apply all conventions from the first line of code. Don't write quick-and-dirty first and refactor later.

#### No extraneous changes
Don't make changes outside the scope of the current task. If a change becomes unnecessary mid-task (e.g., a refactor was needed for an earlier approach but not the final one), revert it. Each MR should contain only the changes required to accomplish its stated goal.

#### Use constants instead of magic strings
When the same string literal is used in more than one place (paths, keys, names, etc.), extract it to a constant. Don't duplicate magic strings across files or even within the same file.

#### Use constants for defaults
Default values (fallback strings, status codes, error codes, log messages) should be named constants, even if used only once. Names give meaning that magic values don't.

#### No kitchen-sink files
Don't create generic catch-all files like `constants.ts`, `utils.ts`, `helpers.ts`, or `types.ts` that accumulate unrelated content. Group constants and utilities by their purpose into specific, focused files (e.g., `routes.ts` for route paths, `errorCodes.ts` for error codes). If you find yourself reaching for a kitchen-sink name, that's a sign the grouping needs more thought.

#### Put code where the folder name says it belongs
A folder's name is a promise about what's inside. Domain-matching (`pipelineFoo.ts` → `services/pipeline/`) is *not enough* — the folder has a semantic contract, not just a domain scope.

**Two-step check before adding a file to a folder:**

1. **`ls` the target folder and read one existing file.** What kind of file is it — a service (has side effects, calls external systems)? A type (compile-time only)? A pure helper? A GraphQL string?
2. **Does the file you're about to add fit that kind?** If yes, add it. If no, look for a folder whose contract matches — even if the domain name is less obvious.

Concrete contracts to internalize:

- `types/` and `types/<domain>/` — TypeScript types, Zod schemas, and type-shaping consts only. If you're writing `export function`, you're in the wrong folder. Even factories that *return* schemas (e.g. `includeQueryParam(allowlist)`) are functions — move them.
- `services/<domain>/` — **env-dependent business logic**. Calls Hasura, external APIs, has side effects. `pipelineFoo` being pipeline-related is not enough; if it's a pure function, it's not a service.
- `shared/<technology>/<domain>/` — cross-cutting utilities scoped to a technology (e.g. `shared/hasura/pagination/`, `shared/hasura/pipeline/`). Nest by tech first, then by domain.
- `<resource>/queries/` — GraphQL query strings only. Not TypeScript helpers that produce query variables.
- `constants.ts` / `utils.ts` / `helpers.ts` — see the kitchen-sink rule above. Split by purpose from day one.

When you catch yourself thinking "well, it's pipeline-related so it goes in `pipeline/`" — that's shallow domain-matching. Ask *what kind of thing is this*, then find a folder whose contract accepts that kind.

#### Use existing libraries instead of rolling your own
Before writing custom code for a common problem (auth, validation, parsing, etc.), look for a well-maintained library that already solves it. Don't hand-roll JWT validation, header parsing, or similar infrastructure when a purpose-built library exists.

### Architecture
#### Thin handlers, fat services
API/route handlers should be thin: parse the request, call a service, shape the response. Business logic lives in a service module — either a class or a collection of exported functions, whichever fits. Unit-test the service directly (cover all branches and edge cases). API tests for the handler should be happy-path only — they verify wiring, not logic. This keeps the bulk of tests fast and focused, and avoids re-running the same business-logic assertions through HTTP for every variant.

### Code Construction
#### Don't make a lot of comments
Don't excessively make comments everywhere. You should pretty much never make comments unless it is a top level comment for a complex part of the code.

#### No single-letter variable names
No single-letter variable names — including in callbacks, loop counters, and import aliases. `error` not `e`, `index` not `i`, `zod` not `z`, `request` not `r`. Library conventions (like zod's canonical `z`) don't override this — rename on import.

#### Object bag args when more than 1 positional
One positional argument is fine. Two or more → destructured options object. Even at two args, the call site is unreadable (`updatePipeline(pipelineId, patch)` — which is which?) and unstable to reorder. At three-plus it's untenable.

```ts
// Bad
export default async function updatePipeline(pipelineId, patch) { ... }
updatePipeline(id, { name: 'foo' });

// Good
export default async function updatePipeline({ pipelineId, patch }) { ... }
updatePipeline({ pipelineId: id, patch: { name: 'foo' } });
```

Applies everywhere — exported surface, internal helpers, closures. Positional-past-one is never grokable at the call site, regardless of scope.

#### Decompose long functions
Decompose long functions or chunks of code as much as possible and practical. Functions should average about 20 lines. This isn't a hard limit, just a target.

#### Avoid deep nesting
Don't nest deeply. If a factory function returns a long inner function, extract the inner function to the top level. Prefer early returns over nested if/else blocks.

#### Delete unused code
If you make a refactor leaving some code orphaned and unused, make sure to also delete it. 

#### Break up dense one-liners with named intermediates
LLMs tend to pack multiple operations into a single line — nested calls inside callbacks inside `await`s. It reads dense to humans even when it's technically correct. Extract each step into a named intermediate variable so a reader can follow one concept at a time. Applies in tests too.

```ts
// Bad — reader parses four things at once (client construction, arrow fn, service call, auth wrap)
const result = await runWithAuth(TEST_AUTH, () => getPipelineByWritekey(WRITEKEY, createHasuraClient(server.url)));

// Good
const client = createHasuraClient(server.url);
const result = await runWithAuth(TEST_AUTH, () => getPipelineByWritekey(WRITEKEY, client));
```

The line-count cost is tiny; the "read once and move on" savings are worth it. Same idea when you're tempted to chain three `.map().filter().reduce()` calls or inline a JSX fragment with computed props.


#### Don't use doc comments excessively
If there is a tiny function with one parmaeter it doesn't need a giant doc block. Only give doc blocks to top level functions that have more than two parameters. 

### JavaScript
#### Never use the delete operator
Never use the delete operator.

#### Never use HTML style attribute
Never use the HTML `style` attribute. Prefer component props or MUI `sx` in rare exceptional cases.
 

### Testing
#### Use project scripts, not raw commands
When a project has a Makefile, npm scripts, or similar wrappers, use those (`make lint`, `make test`, `npm run lint`) instead of invoking tools directly (`npx eslint`, `npx tsc`). The scripts are the project's interface and may include flags or config that raw commands miss.

#### Always run tests before pushing
After making changes, always run the relevant test suites (unit tests, cypress tests) locally and confirm they pass before pushing. Don't assume changes are safe just because the build succeeds — test selectors, test-ids, and component APIs can break tests silently.

#### Update tests when changing component APIs
When migrating or refactoring components, check for cypress tests and unit tests that reference the old component's selectors, test-ids, props, or structure. Update those tests as part of the same change — don't leave them to fail in CI.

#### Cypress
In cypress tests, prefer updating code to use test-ids rather than CSS selectors.
