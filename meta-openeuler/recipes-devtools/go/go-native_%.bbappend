require go-openeuler-common.inc

do_configure() {
    :
}

do_compile() {
    export GOROOT_FINAL="${libdir_native}/go"

    # using go binary from openeuler host, need yum install golang
    export GOROOT_BOOTSTRAP="/usr/lib/golang/"

    cd src
    ./make.bash ${GOMAKEARGS}
    cd ${B}
}

