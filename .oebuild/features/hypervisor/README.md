# Hypervisor feats guide

## what does this category contain

- `baremetal.yaml`: keeps the openAMP path as the default.
- `xen.yaml`: injects Xen-specific distro features and the matching MCS flag.
- `jailhouse.yaml`: replaces the openAMP stack with Jailhouse in `MCS_FEATURES`.

## how these files are used

The `mcs/mica.yaml` feature exposes a **hypervisor** choice that picks exactly
one of the files above, guaranteeing that baremetal, Xen, or Jailhouse wins
and the dependent config flows into the menuconfig experience.
