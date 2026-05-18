**Project: PTXdist**

**Review Focus (priority order):**
1. **Reproducible builds**:
   - All relevant configure options explicitly set — no autodetection left unconstrained
   - `<PKG>_CONF_OPT` starts with the correct default (`$(CROSS_AUTOCONF_USR)`, `$(CROSS_CMAKE_USR)`, etc.) before adding extra options
   - Cache variables (`ac_cv_*`) used to enforce autodetection outcomes where no configure option exists
   - `<PKG>_CONF_ENV` starts with the correct default (`$(CROSS_ENV)` / `$(HOST_ENV)`) before adding extras
   - `configure_helper.py` should have been run for autoconf/meson/cmake packages — new options in upstream covered?
2. **Licensing**:
   - `<PKG>_LICENSE` present and uses valid SPDX expression (or `custom`, `proprietary`, `ignore`, `unknown`)
   - `<PKG>_LICENSE_FILES` present: `file://` URLs relative to `<PKG>_DIR`, each with `md5=<checksum>`; `startline=`/`endline=` used if file contains more than license text
   - On version bumps: `ptxdist licensecheck` run? License checksum still valid? If license file changed, change described in commit message?
   - `<PKG>_CVE_PRODUCT` set if package name differs from CVE database product name
3. **Package version / source**:
   - `<PKG>_VERSION` set and correct
   - `<PKG>_SHA256` preferred over legacy `<PKG>_MD5` for source archive checksum
   - `<PKG>_URL` provides at least one working mirror or fallback URL
   - Git URLs: `tag=<tagname>` option present; `submodules=` only if genuinely needed
   - `<PKG>` variable defined as `<name>-$(<PKG>_VERSION)` pattern
4. **Patches**:
   - Existing patches updated or removed after version bump — `ptxdist lint` would catch stale patches
   - Patch series applies cleanly to new version
   - Patch filenames descriptive; no binary patches without justification
5. **Kconfig / menu files**:
   - New top-level option and non-obvious suboptions have `help` text
   - Suboptions justified: avoid unnecessary ones; use for disk-space savings or high-level feature gates
   - `PTXCONF_*` variables and macros in menu files valid — `ptxdist lint` catches unknown symbols
   - No overly fine-grained low-level suboptions; distil to high-level use-cases
6. **Rule file correctness**:
   - Commented-out default template stages removed (only custom stages remain)
   - `<PKG>_MAKE_PAR := NO` set only if build system genuinely cannot handle parallel builds
   - `<PKG>_PATH` overridden only when necessary (e.g. qmake from Qt5 path)
   - `<PKG>_FLAGS_BLACKLIST` used to prevent implicit library dependencies where needed
   - `<PKG>_BUILD_OOT := YES` for cmake packages (default); justified if changed
   - `targetinstall` stage installs into `$(PKGDIR)` only — no hardcoded host paths
   - PTXdist global variables used throughout (`$(PTXDIST_SYSROOT_TARGET)`, `$(CROSS_PATH)`, `$(ROOTDIR)` etc.) — no hardcoded paths
7. **`ptxdist lint`**:
   - Would `ptxdist lint` flag anything? Stale patches, unknown `PTXCONF_*` variables, missing license info?
8. **Commit message**: check each commit against PTXdist conventions:
   - Fetch last 10 commits touching same files for style baseline
   - Subject: descriptive, concise; prefix identifies the package or subsystem (e.g. `foo: bump version to 1.2.3`, `foo: fix build with gcc-14`)
   - Body required for non-obvious changes: what changed and why
   - `Signed-off-by: Full Name <real@email>` present — real name required (no pseudonyms), GPLv2 DCO
   - License file changes must be described in the commit body
   - Version bumps: mention new version, any notable upstream changes, patch status
9. **Style** (only flag if real problem):
   - No trailing whitespace
   - Make variable assignment style consistent with surrounding file
   - Line continuations (`\`) properly aligned

**Subsystem-Specific Rules:**

- **New packages**: template default stages removed? `<PKG>_LICENSE` + `<PKG>_LICENSE_FILES` present? Top-level Kconfig option has `help`? `<PKG>_SHA256` set?
- **Version bumps**: patches updated/removed? License checksum rechecked (`ptxdist licensecheck`)? New configure options covered (`configure_helper.py`)? `<PKG>_MD5`/`<PKG>_SHA256` updated?
- **autoconf packages**: `<PKG>_CONF_OPT` starts with `$(CROSS_AUTOCONF_USR)`? All relevant `--enable-`/`--disable-`/`--with-`/`--without-` options explicit?
- **cmake packages**: `<PKG>_CONF_OPT` starts with `$(CROSS_CMAKE_USR)`? `HOST_CMAKE` selected in Kconfig? `<PKG>_BUILD_OOT` set?
- **python packages**: `<PKG>_CONF_TOOL := python3`? `<PKG>_MAKE_ENV` based on `<PKG>_CONF_ENV`?
- **kernel / bootloader packages**: `<PKG>_WRAPPER_BLACKLIST` used to disable hardening injections that break the build?
- **image packages**: `<PKG>_IMAGE` points to `$(IMAGEDIR)/`? `<PKG>_FILES` or `<PKG>_PKGS` dependencies correct? `genimage` config in `config/images/`?
- **layers**: rule uses `$(call ptx/get-alternative, ...)` or layer-aware macros where appropriate? Layer search order respected?
