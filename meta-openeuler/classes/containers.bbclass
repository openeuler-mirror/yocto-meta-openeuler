# containers.bbclass - Common container runtime support
#
# This bbclass provides common configuration for container runtime support.
# When DISTRO_FEATURES contains "containers", this class is inherited to set up
# kernel configurations and container engine runtime selection.

# Set container engine runtime based on DISTRO_FEATURES
# This ensures VIRTUAL-RUNTIME_container_engine is populated for future use
python populate_container_engine() {
    d = d
    # Check for specific container engine features
    engines = []
    if bb.utils.contains('DISTRO_FEATURES', 'containerd', True, False, d):
        engines.append('containerd')
    if bb.utils.contains('DISTRO_FEATURES', 'isulad', True, False, d):
        engines.append('isulad')
    if bb.utils.contains('DISTRO_FEATURES', 'docker', True, False, d):
        engines.append('docker')
    if bb.utils.contains('DISTRO_FEATURES', 'podman', True, False, d):
        engines.append('podman')

    if engines:
        # Append to VIRTUAL-RUNTIME_container_engine, preserving existing values
        current = d.getVar('VIRTUAL-RUNTIME_container_engine') or ''
        current_list = current.split()
        for engine in engines:
            if engine not in current_list:
                current_list.append(engine)
        d.setVar('VIRTUAL-RUNTIME_container_engine', ' '.join(current_list))
}

# Execute the population function after parsing
addhandler populate_container_engine
populate_container_engine[eventmask] = "bb.event.ParseStarted"

# Add container kernel configuration task dependency
# This ensures do_container_configs task is added when containers feature is enabled
addtask container_configs before do_compile after do_configure

# Prevent duplicate task addition
python () {
    # If containers feature is enabled, ensure container_configs task is added
    # This duplicates the logic in linux-openeuler.inc but ensures consistency
    if bb.utils.contains('DISTRO_FEATURES', 'containers', True, False, d):
        # The task is already added by linux-openeuler.inc, but we add it here for completeness
        # The addtask above should be sufficient
        pass
}