**Project: Yocto Project / OpenEmbedded Layer**

**Review Focus (priority order):**
1. **Recipe naming**: `recipes-<category>/<name>/<name>_<version>.bb` convention followed? Hyphens OK in name/category, not in version. Git-only recipes use `_git.bb` + `PV` set correctly?
2. **Version / PV / PE / PR**:
   - `PV` sorts correctly — pre-release uses tilde form (`1.5~rc2` not `1.5rc2`)
   - Git recipes: `PV = "<lastrelease>+git"` (not bare `+git` without version)
   - `PR` removed when `PV` increases
   - `PE` bumped when `PV` would otherwise decrease (set to `"1"` if unset, not `"0"`)
3. **License fields**:
   - `LICENSE` present, uses SPDX name from `meta/files/common-licenses/` (e.g. `GPL-2.0-only`, not `GPLv2`)
   - `LIC_FILES_CHKSUM` present and covers all applicable license files
   - If `LICENSE` or `LIC_FILES_CHKSUM` changed: `License-Update:` tag present in commit message with reason
4. **Required metadata**: all recipes have `SUMMARY`, `HOMEPAGE`? `DESCRIPTION` if non-trivial? `BUGTRACKER` if applicable?
5. **Recipe variable ordering**: follows canonical order:
   `SUMMARY` → `DESCRIPTION` → `HOMEPAGE` → `BUGTRACKER` → `SECTION` → `LICENSE` → `LIC_FILES_CHKSUM` → `DEPENDS` → `PROVIDES` → `PV` → `SRC_URI` → `SRCREV` → `S` → `inherit` → `PACKAGECONFIG` → build vars → tasks → `PACKAGE_ARCH` → `PACKAGES` → `FILES` → `RDEPENDS` → `RRECOMMENDS` → `BBCLASSEXTEND`
6. **Recipe formatting**:
   - Variable assignment: space around operator (`FOO = "bar"` not `FOO="bar"`)
   - Double quotes on RHS (not single quotes)
   - 4 spaces for indentation (not tabs), except shell functions where layer convention applies
   - Long variables split with `\` continuation, continuation lines aligned to opening quote
7. **Patches**:
   - Every patch has `Upstream-Status:` tag: `Pending` | `Submitted [where]` | `Backport [version]` | `Denied` | `Inactive-Upstream` | `Inappropriate [reason]`
   - `Inappropriate` only for `oe specific` or `upstream ticket <link>` — no other reasons accepted
   - CVE patches have `CVE: CVE-YYYY-NNNNN` tag (space-separated if multiple)
   - No git version signature at end of patch (`format.signature ""`)
   - Patch description includes bug URL / mailing list link
8. **`BBCLASSEXTEND`**: used instead of separate `-native`/`-nativesdk` recipes where possible
9. **Task idempotency**: tasks that modify files use copy-to-`.orig`-then-modify pattern to be re-runnable safely
10. **`DEPENDS` vs `RDEPENDS`**: build-time deps in `DEPENDS`, runtime deps in `RDEPENDS:${PN}`; not mixed
11. **`select` vs `DEPENDS`**: layer Kconfig / `PACKAGECONFIG` deps correct? No silent pulls of large features
12. **AI-generated code**: if AI-assisted, commit message must have `AI-Generated: <tool>` line before `Signed-off-by`; code itself should have comment indicating AI generation
13. **Commit message**: Check each commit message against Yocto/OE conventions:
    - Fetch the last 10 commits touching the same files to establish layer style baseline
    - **[WAGO mandatory]** Subject must start with a WAGO ticket prefix matching `(YBP|WAT)-[0-9]+` (e.g. `YBP-11254:`, `WAT-38939:`). Separator after ticket ID is `:` or ` -`. Flag any commit missing this prefix, or using any other prefix, as a violation.
    - Subject part after ticket ID matches file/recipe path — check `git log --oneline <path>` for convention
    - Subject line short and descriptive; no trailing period
    - Blank line after subject; body describes what/why/how
    - `Signed-off-by:` present (`git commit -s`)
    - Bug reference format: `Fixes [YOCTO #<id>]` in body if applicable
    - Credit tags used where appropriate: `Reported-by`, `Suggested-by`, `Tested-by`, `Reviewed-by`
    - Re-submissions: `[PATCH v2]` prefix + changelog after `---` marker listing changes per version
    - New files in layer: license comment or `SPDX-License-Identifier` at top, matching layer license
    - Layer prefix in subject for non-OE-core patches (e.g. `[meta-oe][PATCH]`)
14. **Style** (only flag if causes real problems):
    - No trailing whitespace
    - Consistent indentation within a recipe (check layer convention)
    - `patchtest` violations only if clearly meaningful

**Subsystem-Specific Rules:**

- **New recipes**: previous version deleted in same commit as new version? `BBCLASSEXTEND` used for native/nativesdk if applicable? `SRC_URI` checksums present?
- **Recipe upgrades**: `PR` removed? `LIC_FILES_CHKSUM` updated if license files changed? `SRCREV` pinned (not `AUTOREV`) for published layers?
- **Kernel recipes** (`linux-*.bb`): `LINUX_VERSION` set? `KBRANCH` correct? `SRCREV` pinned?
- **BSP layers**: `COMPATIBLE_MACHINE` set to restrict recipe to correct machines? `PACKAGE_ARCH = "${MACHINE_ARCH}"` where needed?
- **`SRC_URI` patches**: applied in correct order? Patch filenames descriptive? No binary patches without justification?
- **`do_install`**: installs into `${D}` only, not into host paths? Uses `install -d` before `install -m`?
- **`FILES`**: all installed files accounted for in `FILES:${PN}` or sub-packages? No stray `/usr/local` paths?
- **Stable branch backports**: fix already in master? Subject prefix includes branch name (e.g. `walnascar][PATCH`)? CVE or bug ID referenced?
- **Submodule / sublayer PRs**: when a main project PR includes a submodule update commit alongside a sublayer PR:
  - Verify the submodule pointer in the main PR matches the HEAD commit of the sublayer PR — mismatch = wrong revision pinned
  - Review sublayer changes first, then validate the main project submodule bump is the only change in that commit
  - Check the sublayer PR commit messages independently against the WAGO ticket prefix rule
  - Submodule update commit in main project should reference the same WAGO ticket: `YBP-NNNNN: <layer>: update submodule`

