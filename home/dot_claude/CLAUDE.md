## Local Settings

### Git
#### Always create draft PRs
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
When writing code, apply the community's established best practices from the start without being asked. Don't write something the quick way knowing a better pattern exists and wait for the user to catch it. The user shouldn't have to ask "what do developers typically do here?" for you to do the right thing.

#### Follow project conventions from the start
Before writing new code, read the project's CONVENTIONS.md (or equivalent) and apply all conventions from the first line of code. Don't write quick-and-dirty first and refactor later.

#### No extraneous changes
Don't make changes outside the scope of the current task. If a change becomes unnecessary mid-task (e.g., a refactor was needed for an earlier approach but not the final one), revert it. Each PR should contain only the changes required to accomplish its stated goal.

#### Use constants instead of magic strings
When the same string literal is used in more than one place (paths, keys, names, etc.), extract it to a constant. Don't duplicate magic strings across files or even within the same file.

#### Use constants for defaults
Default values (fallback strings, status codes, error codes, log messages) should be named constants, even if used only once. Names give meaning that magic values don't.

#### No kitchen-sink files
Don't create generic catch-all files like `constants`, `utils`, `helpers`, or `types` that accumulate unrelated content. Group constants and utilities by their purpose into specific, focused files (e.g., a `routes` file for route paths, an `errorCodes` file for error codes). If you find yourself reaching for a kitchen-sink name, that's a sign the grouping needs more thought.

#### Use existing libraries instead of rolling your own
Before writing custom code for a common problem (auth, validation, parsing, etc.), look for a well-maintained library that already solves it. Don't hand-roll JWT validation, header parsing, or similar infrastructure when a purpose-built library exists.

### Architecture
#### Thin handlers, fat services
API/route handlers should be thin: parse the request, call a service, shape the response. Business logic lives in a service module — either a class or a collection of functions, whichever fits. Unit-test the service directly (cover all branches and edge cases). API tests for the handler should be happy-path only — they verify wiring, not logic. This keeps the bulk of tests fast and focused, and avoids re-running the same business-logic assertions through HTTP for every variant.

### Code Construction
#### Don't make a lot of comments
Don't excessively make comments everywhere. You should pretty much never make comments unless it is a top level comment for a complex part of the code.

#### No single-letter variable names
No single-letter variable names — including in callbacks, loop counters, and import aliases. `error` not `e`, `index` not `i`, `request` not `r`. Library conventions that use single-letter names don't override this — rename on import.

#### Decompose long functions
Decompose long functions or chunks of code as much as possible and practical. Functions should average about 20 lines. This isn't a hard limit, just a target.

#### Avoid deep nesting
Don't nest deeply. If a factory function returns a long inner function, extract the inner function to the top level. Prefer early returns over nested if/else blocks.

#### Delete unused code
If you make a refactor leaving some code orphaned and unused, make sure to also delete it. 

#### Break up dense one-liners with named intermediates
LLMs tend to pack multiple operations into a single line — nested calls inside callbacks inside chained/async calls. It reads dense to humans even when it's technically correct. Extract each step into a named intermediate variable so a reader can follow one concept at a time. Applies in tests too, and to chained functional pipelines or deeply nested expressions generally. The line-count cost is tiny; the "read once and move on" savings are worth it.

#### Don't use doc comments excessively
If there is a tiny function with one parameter it doesn't need a giant doc block. Only give doc blocks to top level functions that have more than two parameters. 

### Testing
#### Use project scripts, not raw commands
When a project has a Makefile, npm scripts, or similar wrappers, use those instead of invoking tools directly. The scripts are the project's interface and may include flags or config that raw commands miss.

#### Always run tests before pushing
After making changes, always run the relevant test suites locally and confirm they pass before pushing. Don't assume changes are safe just because the build succeeds — implementation details like selectors, test-ids, or component/function APIs can break tests silently.

#### Update tests when changing public APIs
When migrating or refactoring code, check for tests that reference the old implementation's interface or structure. Update those tests as part of the same change — don't leave them to fail in CI.
