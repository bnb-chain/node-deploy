# reth-bsc Pending Changes

These are local (uncommitted) changes in the `reth-bsc` repo that have not been pushed upstream.
They need to be applied before building reth-bsc with heap profiling support.

## Branch: `develop`

### 1. `Cargo.toml` — Add `jemalloc-prof` feature

A dedicated `jemalloc-prof` feature is needed so that profiling can be compiled in without
forcing it on all `jemalloc` users. Currently the `jemalloc` feature does not enable the
`profiling` sub-feature of tikv-jemallocator.

**Change:** add the following line in the `[features]` section, after the `jemalloc` line:

```toml
jemalloc-prof = ["dep:tikv-jemallocator", "tikv-jemallocator/profiling", "reth/jemalloc"]
```

Full context:

```toml
[features]
default = ["jemalloc"]
jemalloc = ["dep:tikv-jemallocator", "reth/jemalloc"]
jemalloc-prof = ["dep:tikv-jemallocator", "tikv-jemallocator/profiling", "reth/jemalloc"]  # <-- add this
dev = ["reth-cli-commands/arbitrary", "reth/dev", "revm/dev"]
asm-keccak = [
    ...
]
```

### 2. `src/main.rs` — Activate jemalloc allocator for `jemalloc-prof` feature

The `#[global_allocator]` declaration was gated only on the `jemalloc` feature. It must also
activate when `jemalloc-prof` is used, otherwise the profiling allocator is compiled in but
never registered.

**Change:** update the `#[cfg]` attribute from:

```rust
#[cfg(all(feature = "jemalloc", unix))]
```

to:

```rust
#[cfg(all(any(feature = "jemalloc", feature = "jemalloc-prof"), unix))]
```

---

## Why these changes exist

The node-deploy README documents a `cargo build` command that uses `--features jemalloc-prof,asm-keccak`
for heap profiling. Without these two changes the build will fail because `jemalloc-prof` is not
a recognised feature and the global allocator will not be set correctly.

## How to apply

```bash
cd /path/to/reth-bsc
# Edit Cargo.toml and src/main.rs as described above, then:
cargo build --bin reth-bsc --profile profiling --features jemalloc-prof,asm-keccak
```
