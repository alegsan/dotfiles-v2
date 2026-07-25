**Project: Linux Kernel**

**Review Focus (priority order):**
1. **Memory safety**: alloc/free pairs, use-after-free, double-free, missing `kfree` on every error path
   - `kmalloc`/`kzalloc`: prefer `sizeof(*p)` form, not `sizeof(struct foo)`
   - Arrays: prefer `kmalloc_array(n, sizeof(...))` or `kcalloc(n, sizeof(...))` — both check overflow
   - Cast of `void *` return from allocator is redundant — flag it
2. **Locking**: lock order violations, missing locks on shared data, sleeping in atomic context
   - All memory barriers (`barrier()`, `rmb()`, `wmb()`, `smp_mb()`) must have a comment explaining the logic
   - Data structures visible outside single-threaded context must have reference counts
   - Locking ≠ reference counting — both may be needed
3. **Error paths**: reverse-order cleanup, all `goto` labels descriptive (e.g. `out_free_buffer:` not `err1:`)
   - Watch for null-pointer `kfree` on shared error labels — may need split labels
   - No `BUG()` / `BUG_ON()` in new code — use `WARN_ON_ONCE()` with recovery where possible
   - `panic()` only acceptable during boot for unrecoverable situations
4. **Integer overflow**: `size_t` vs `int`, `u32` arithmetic before cast, unchecked return values
   - Signed/unsigned comparison warnings (`gcc -W`) are real bugs — do not ignore
5. **Sparse annotations**: `__user`, `__rcu`, `__iomem`, `__must_hold` — correct and consistent?
6. **API contracts**: caller preconditions met? refcounts bumped before use? RCU read lock held?
   - Functions returning error codes: name is action/command → return `-Exxx` on fail, `0` on success
   - Functions returning bool predicate: return `1` success, `0` fail — never mix the two conventions
   - No new `typedef` for structs/pointers unless it meets one of the documented exceptions (opaque type, sparse type, u8/u16/u32/u64)
7. **Kconfig**:
   - New symbols default to `off` unless exception criteria met
   - All new `CONFIG` options have `help` text
   - `IS_ENABLED()` used instead of `#ifdef` in `.c` files where possible
   - Non-trivial `#ifdef` blocks end with `#endif /* CONFIG_SOMETHING */`
   - `__maybe_unused` instead of `#ifdef` wrapping for potentially unused functions/variables
8. **Inline**: functions >3 lines not marked `inline` without justification
   - No macros resembling functions where `static inline` can be used instead
   - Multi-statement macros wrapped in `do { } while (0)`
   - Macros defining constants: expression in parentheses
9. **Crash avoidance**:
   - No new `BUG()` / `BUG_ON()` / `VM_BUG_ON()` — use `WARN_ON_ONCE()` + recovery
   - `BUILD_BUG_ON()` encouraged for compile-time assertions
   - `WARN*()` only for truly unexpected conditions, not normal operation paths
10. **Licensing / SPDX**:
    - New files: `// SPDX-License-Identifier: GPL-2.0` (or compatible) on first possible line
    - C headers use `/* SPDX-License-Identifier: ... */` style
    - DTS/DTSI use `// SPDX-License-Identifier: ...` style
    - UAPI headers: `GPL-2.0 WITH Linux-syscall-note`
    - New modules: `MODULE_LICENSE("GPL")` present and consistent with SPDX tag?
    - Dual-licensed files: `OR` between identifiers (e.g. `GPL-2.0 OR MIT`)
    - Backported code: original project, version, and commit ID noted in commit message
11. **Commit message**: Check each commit message against Linux kernel conventions:
    - Fetch the last 10 commits touching the same files to establish subsystem style baseline
    - Subject line ≤72 chars, no trailing period, imperative present tense (`Add X` not `Added X`)
    - Subsystem prefix correct — check `git log <file>` to match local convention
    - Blank line after subject; body lines ≤75 chars
    - `Fixes: <12-char-sha> ("subject line")` — exact format, `Cc: stable@vger.kernel.org` where applicable
    - `Signed-off-by:` present; if backport, `Link:` to original upstream commit
    - New `/proc` entries, boot parameters, module params, userspace interfaces, ioctls — documented?
12. **Style** (only flag if causes real problems):
    - 8-char TAB indentation; no spaces for indentation
    - Lines >80 chars only if readability genuinely improves — never break user-visible strings (breaks `grep`)
    - No trailing whitespace
    - Opening brace at end of line for all blocks except function definitions
    - No editor modelines (`vim:`, `emacs:`) in source files
    - `checkpatch.pl` violations only if meaningful

**Subsystem-Specific Rules:**

- **net / net-next**: `skb` ownership — who frees on error? `kfree_skb` vs `consume_skb` correct? RCU dereference with `rcu_read_lock()` held? `GFP_ATOMIC` in softirq/atomic context (not `GFP_KERNEL`)? NAPI budget respected? `napi_complete_done` called correctly?
- **mm**: GFP flags match context. `__GFP_NOFAIL` justified? Folio refcounts balanced? VMA vs mmap_lock — correct lock held? `vmalloc` vs `kmalloc` trade-off justified?
- **drm**: `drm_device` lifetime — object freed before unregister? Modeset lock hierarchy respected? Fence signaling on all code paths? GEM object refcounts balanced?
- **fs / vfs**: dentry/inode refcounts balanced? RCU pathwalk rules respected? `sb_writers`/`i_rwsem` order correct? `copy_to_user`/`copy_from_user` return value checked?
- **drivers (general)**: `probe` error path releases all resources in reverse order? DMA `dma_map_*` return checked? `dma_unmap_*` on every exit path? Mixed `devm_*` / manual without clear reason is a red flag. `pm_runtime_get_sync` error path handled?
- **arch**: `barrier()`/`smp_mb()`/`wmb()` has explanatory comment? `asm volatile` constraints correct? UACCESS region kept minimal? Large non-trivial asm in `.S` files with C prototypes using `asmlinkage`?
