# GLib 2.0 ABI Compatibility Check

## Overview

This directory contains pre-built GLib ABI compatibility check programs for four architectures. These programs are used to verify that the GLib runtime library on the target device is ABI-compatible with the GLib version used during cross compilation.

## Checksums

Checksums are stored in standard checksum files:

- `sha256sums` - SHA256 checksums
- `md5sums` - MD5 checksums

Verify integrity:

```bash
sha256sum -c sha256sums
md5sum -c md5sums
```

## How to Build

The check programs are built using the `do_populate_abi_check` task defined in `meta-openeuler/recipes-core/glib-2.0/glib-2.0_%.bbappend`. The source code is `meta-openeuler/recipes-core/glib-2.0/glib-2.0/glib-abi-check.c`.

### Prerequisites

- An openEuler Embedded build environment (oebuild) configured for the target architecture
- GLib 2.0 recipe has been built (at least through `do_install`)

### Build Steps

```bash
# Enter the build directory for the target architecture
oebuild bitbake glib-2.0 -c do_populate_abi_check
```

The compiled binary will be located at:
```
tmp/work/<arch>/glib-2.0/<version>/build/glib-abi-check
```

Note: The `do_populate_abi_check` task does NOT run automatically during normal builds. It must be explicitly invoked with `-c do_populate_abi_check`.

### Build Details

The task compiles `glib-abi-check.c` against the installed GLib headers and libraries from `${D}` (the install directory), ensuring that the check program is linked against the same GLib version that will be deployed to the target.

## How to Run

1. Copy the appropriate binary to the target device:

```bash
scp glib-abi-check-<arch> root@<target-ip>:/root/glib-abi-check
```

2. Run the check program on the target:

```bash
chmod +x /root/glib-abi-check
/root/glib-abi-check
```

3. Check the output. A successful run shows:

```
========================================
GLib 2.0 ABI Check
Compile-time GLib version: 2.78.3
Runtime GLib version: 2.78.3
========================================

[PASS] Compile-time and runtime GLib version match

[1/4] Basic type size check
[PASS] sizeof(gint) == 4
...

Total: 25  Passed: 25  Failed: 0
========================================
GLib 2.0 ABI compatible!
```

If any test fails, the program returns exit code 1 and prints `GLib 2.0 ABI incompatible!`.

## What It Checks

The program performs the following checks:

### [1/4] Version Match

Verifies that the compile-time GLib version (from headers) matches the runtime GLib version (from the shared library). A version mismatch indicates that the target device has a different GLib version than what was used during compilation.

### [2/4] Basic Type Size Check

Verifies that fundamental GLib types have the expected sizes:

| Type | Expected Size |
|---|---|
| gint | 4 bytes |
| guint | 4 bytes |
| gint64 | 8 bytes |
| guint64 | 8 bytes |
| gpointer | sizeof(void*) |
| gsize | sizeof(size_t) |
| gssize | sizeof(ssize_t) |

### [3/4] Core Data Structure Layout Check

Verifies that core GLib data structures have valid layouts and prints their actual sizes for reference:

| Structure | Description |
|---|---|
| GString | Dynamic string (prints actual size) |
| GList | Doubly-linked list (expected: 3 * sizeof(gpointer)) |
| GSList | Singly-linked list (expected: 2 * sizeof(gpointer)) |
| GArray | Dynamic array (prints actual size) |
| GByteArray | Byte array (expected: same as GArray) |
| GError | Error reporting (prints actual size) |

### [4/4] Enum and Constant Check

Verifies that GType fundamental type constants are valid at runtime using `G_TYPE_IS_FUNDAMENTAL()`, and that GSeekType enumeration values are distinct. Prints actual values for reference.

### [5/4] Core Function Check

Tests that fundamental GLib functions work correctly:

| Function | What it tests |
|---|---|
| g_malloc / g_free | Memory allocation and deallocation |
| g_strdup | String duplication |
| g_string_new / g_string_free | Dynamic string creation |
| g_list_append / g_list_free | Doubly-linked list operations |
| g_hash_table_new / g_hash_table_destroy | Hash table creation and destruction |

## Troubleshooting

- **Version mismatch**: Ensure the GLib version on the target matches the one used during cross compilation.
- **Type size mismatch**: May indicate a 32-bit vs 64-bit mismatch between the compiled binary and the target environment.
- **Function test failure**: May indicate that the GLib shared library on the target is corrupted or incompatible.
- **Permission denied**: The target /tmp may be mounted with noexec. Copy the binary to /root or another directory with execute permission.
