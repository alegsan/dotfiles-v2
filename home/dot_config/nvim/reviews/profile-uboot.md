**Project: U-Boot Bootloader**

**Review Focus (priority order):**
1. **Memory safety**: `malloc`/`free` pairs, missing `free` on every error path — U-Boot has no MMU safety net
2. **Error paths**: return code checked? `CMD_RET_FAILURE` vs `CMD_RET_SUCCESS` correct? `ret` pattern used consistently?
3. **Driver model (DM)**:
   - `uclass_get_device`, `dev_get_priv`, `dev_get_platdata` usage correct?
   - `probe`/`remove` symmetry? Resources released in `remove`?
   - Variable naming: `priv` for `dev_get_priv()`, `plat` for `dev_get_platdata()`
   - Return values via `log_ret()` or `log_msg_ret()`?
   - Out-params use `p` suffix (e.g. `devp`)?
4. **Environment**: `env_get`/`env_set` usage correct? Default fallbacks handled?
5. **Platform data vs DT**: DT-first preferred; platform data only for SPL where DT overhead is justified
6. **SPL constraints**: no dynamic alloc in SPL where `CONFIG_SPL_MALLOC` not enabled; stack usage minimal
7. **Kconfig / defconfig**:
   - New symbols have `default`, `depends on`, `help`?
   - `select` vs `depends on` used correctly? No silent enabling of large features?
   - `IS_ENABLED()` / `CONFIG_IS_ENABLED()` used instead of `#ifdef` in `.c` files where possible?
   - `#endif` for non-trivial blocks has comment: `#endif /* CONFIG_SOMETHING */`?
   - defconfig sorted (`make savedefconfig`)?
8. **I/O register access**: C struct used to map registers? `check_member()` macro used to verify offsets?
9. **Include file ordering**: alphabetical within groups: top-level includes → subdirectory includes → local includes?
10. **Conditional compilation**: `#if`/`#ifdef` in `.c` files avoided where possible? No-op stubs in headers preferred?
11. **Commit message**: Check each commit message against U-Boot conventions:
    - Fetch the last 10 commits touching the same files to establish subsystem style baseline.
    - Subject line ≤70 chars, no trailing period, imperative/present tense (e.g. `Add support for X` not `Added`)
    - Subsystem prefix present and correct — check `git log <file>` to match local convention (e.g. `net:`, `mmc:`, `board/vendor:`, `dm:`)
    - Blank line after subject
    - Body lines ≤72 chars
    - `Signed-off-by:` present
    - New files: copyright notice + `SPDX-License-Identifier: GPL-2.0+` present?
    - Backported code: origin noted (upstream commit ID, project, version)?
    - Re-submissions: `[PATCH v2]` prefix and `Changes for v2:` section below `---`?
12. **Style** (only flag if causes real problems):
    - No trailing whitespace
    - TAB indentation (not spaces), except Python (4 spaces)
    - No more than 2 consecutive blank lines
    - No trailing blank lines at end of file
    - `clang-format` violations only if clearly wrong, not cosmetic preference

**Subsystem-Specific Rules:**

- **net**: `phy_connect` error checked? `eth_env_get_enetaddr` vs direct `env_get`? `CONFIG_DM_ETH` used?
- **mmc / storage**: `blk_dread`/`blk_dwrite` return value (number of blocks transferred) checked?
- **board files**: `board_init`, `dram_init` return codes correct? `checkboard` output meaningful?
- **DTS / DTSI**: compatible strings match driver? `u-boot,dm-pre-reloc` only where really needed?
- **Function/struct comments**: exported functions documented in header file; static functions documented in `.c` file; error return values listed?
- **Filenames**: underscore preferred over hyphen for `.c`/`.h`; no uppercase; short names?
