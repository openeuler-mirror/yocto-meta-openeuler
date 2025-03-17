# enable cgroup v2
# isulad, embedded, ...
container_runtime_endpoint = "embedded"
PV = "1.22.17-k3s1"
#full_k3s = "false"
MAX_K3S_BINARY_SIZE ?= "61000000"
GO_BUILD_LDFLAGS:append = ""

# overwrite install_other_endpoint() to use other container_runtime_points
install_other_endpoint() {
  # customize install:
  # 1. install airgap images
  # 2. modifiy k3s-install-agent
  # 3. modifiy k3s-agent.service and k3s.service
  bbplain "customize your endpoint install script!"
  bbwarn "rtest"
}

do_sizecheck() {
  bbplain "checking k3s binary size at WORKDIR, modified from ./scripts/binary_size_check.sh"
  SAMPLE="${build_bindir}/k3s"
  BIN_SIZE=$(stat -c '%s' ${SAMPLE})
  if [ ${BIN_SIZE} -gt ${MAX_K3S_BINARY_SIZE} ]; then
    bbwarn "k3s binary ${SAMPLE} size ${BIN_SIZE} exceeds max accetable size of ${MAX_K3S_BINARY_SIZE} bytes"
  else
    bbplain "k3s binary ${SAMPLE} size ${BIN_SIZE} is less than max acceptaable size of ${MAX_K3S_BINARY_SIZE} bytes"
  fi
}

addtask do_sizecheck after do_install
