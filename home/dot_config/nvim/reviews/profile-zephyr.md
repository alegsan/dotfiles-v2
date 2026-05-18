**Project: Zephyr RTOS**

**Review Focus (priority order):**
1. **Memory safety (MISRA-C / Zephyr rules)**:
   - No dynamic memory allocation (`malloc`, `calloc`, `realloc`, `free`, `<stdlib.h>` heap) — MISRA Dir 4.12 / Rule 21.3. Use Zephyr memory pools/slabs instead
   - No VLAs — Rule 18.8
   - No recursion — Rule 17.2
   - Address of automatic storage not copied to outliving pointer — Rule 18.6
   - All dynamically obtained resources explicitly released — Rule 22.1
2. **Error handling**:
   - Every function returning error info must have return value tested — Dir 4.7 / Rule 17.7
   - All exit paths from non-void functions have explicit `return` — Rule 17.4
   - `errno` zeroed before errno-setting function, tested immediately after — Rules 22.8/22.9
3. **Type safety**:
   - Use Zephyr sized types (`u8`/`u16`/`u32`/`u64`/`s8`…) for hardware registers — not bare `int`/`long`
   - No implicit narrowing type conversions — Rules 10.3/10.4
   - Unsigned constants use `U` suffix, no lowercase `l` suffix — Rules 7.2/7.3
   - No octal constants — Rule 7.1; `NULL` only null pointer constant — Rule 11.9
   - `const`/`volatile` not cast away — Rule 11.8; no `restrict` — Rule 8.14
4. **Control flow**:
   - Every `if`/`else if` chain terminated with `else` — Rule 15.7
   - Every `switch` has `default` (first or last) + `break` in every clause — Rules 16.3/16.4/16.5
   - No dead or unreachable code — Rules 2.1/2.2
   - `goto` only jumps forward to label in same or enclosing block — Rules 15.2/15.3
   - Loop and `if`/`else` body always in braces — Rule 15.6
5. **Preprocessor / macros**:
   - Function-like macros: prefer `static inline` — Dir 4.9
   - Multi-statement macros use `do { } while (0)`
   - Macro parameters in expressions enclosed in parentheses — Rule 20.7
   - No `#define`/`#undef` on reserved identifiers — Rules 21.1/21.2
   - No `#ifdef` around function/struct declarations in headers (Rule A.1) — use `IS_ENABLED()` instead
   - Non-trivial `#ifdef` blocks end with `#endif /* CONFIG_SOMETHING */`
   - Common macro names (`MIN`, `MAX`, `ARRAY_SIZE`) must NOT be renamed/prefixed/guarded — Rule A.3
6. **Identifiers / naming**:
   - No shadowing of outer-scope identifiers — Rule 5.3
   - No offensive terms: master/slave → primary/secondary, blacklist/whitelist → denylist/allowlist — Rule A.2
   - `static` on all internal-linkage declarations — Rule 8.8
   - `inline` functions declared `static` — Rule 8.10
7. **C standard library**:
   - Kernel code (`kernel/`, `lib/os/`, `arch/`, `subsys/logging/`): only allowed kernel libc list
   - General codebase: ISO C11 only + `gmtime_r`, `strnlen`, `strtok_r`
   - `<stdarg.h>` not used — Rule 17.1; `<setjmp.h>` not used — Rule 21.4
   - Standard I/O (`printf` etc.) not in embedded code paths — Rule 21.6
8. **Devicetree / Kconfig**:
   - New `Kconfig` symbols have `default`, `depends on`, `help`
   - DTS `compatible` strings match driver
   - `IS_ENABLED(CONFIG_FOO)` preferred over `#ifdef CONFIG_FOO` in `.c` files
9. **Licensing / SPDX**:
   - New files: `SPDX-FileCopyrightText: Copyright The Zephyr Project Contributors` + `SPDX-License-Identifier: Apache-2.0` at top
   - Imported code: `Origin:` / `License:` / `URL:` / `commit:` / `Purpose:` block in commit message
10. **AI-assisted contributions**:
    - If AI tools used: `Assisted-by: [Agent]:[ModelVersion]` tag before `Signed-off-by`
    - `Signed-off-by` must be human submitter only
11. **Commit message**: check against Zephyr conventions:
    - Fetch last 10 commits touching same files for area style baseline
    - Format: `[area]: [summary]` — e.g. `drivers: sensor: abcd:`, `net: ethernet:`, `Bluetooth: Shell:`
    - Title ≤72 chars, blank line after, body **must not be empty**
    - Body: what, why, assumptions, how tested; lines ≤75 chars
    - `Signed-off-by: Full Legal Name <real@email>` — no pseudonyms
    - Issue ref: `Fixes zephyrproject-rtos/zephyr#<number>`; extra links via `Link:` tag
    - `Assisted-by:` before `Signed-off-by:` if AI used
12. **Tooling**:
    - Would `checkpatch.pl` flag this? (Zephyr uses Linux kernel checkpatch)
    - Would `check_compliance.py` flag this? (commit format, style, sorted blocks)
    - `zephyr-keep-sorted-start/stop` markers respected if present in modified files
13. **Style** (only flag if real problem):
    - 8-char TAB indentation (Linux kernel style)
    - No trailing whitespace
    - DTS: `dts-linter` compliance

**Subsystem-Specific Rules:**

- **drivers**: use Zephyr bus APIs (`spi_transceive`, `i2c_transfer`) not SoC-specific paths unless Architecture WG approved; init error path releases all resources
- **Bluetooth**: Bluetooth Appropriate Language Mapping for terms; `bt_` prefix on public API
- **net**: `net_buf` ownership correct? `net_pkt` ref counts balanced?
- **arch**: `barrier()`/`dsb()`/`isb()` must have comment; `__asm__` volatile constraints correct; large asm in `.S` files
- **boards / DTS**: `compatible` in DTS matches driver; pinctrl nodes correct
- **Kconfig**: `select` vs `depends on` correct; no silent large-feature enables
- **tests / samples**: new driver/feature has sample or test? `testcase.yaml` present and correct?
