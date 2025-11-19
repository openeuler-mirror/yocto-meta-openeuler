# [k8s.io/utils v0.0.0-20210819203725-bdf08cb9a70a] git ls-remote https://github.com/kubernetes/utils bdf08cb9a70a05bd10b6fe605643a9cbab6effd5
SRCREV_utils = "bdf08cb9a70a05bd10b6fe605643a9cbab6effd5"
SRC_URI += "git://github.com/kubernetes/utils;name=utils;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/k8s.io/utils"

# [golang.org/x/net v0.0.0-20210405180319-a5a99cb37ef4] git ls-remote https://go.googlesource.com/net a5a99cb37ef4b68617775ab669177656090ab396
SRCREV_net = "a5a99cb37ef4b68617775ab669177656090ab396"
SRC_URI += "git://go.googlesource.com/net;name=net;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/net"

# [golang.org/x/sys v0.0.0-20210616094352-59db8d763f22] git ls-remote https://go.googlesource.com/sys 59db8d763f22395595c26ee1cae0886b57141b3a
SRCREV_sys = "59db8d763f22395595c26ee1cae0886b57141b3a"
SRC_URI += "git://go.googlesource.com/sys;name=sys;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/sys"

# [gopkg.in/yaml.v2 v2.4.0] git ls-remote https://github.com/go-yaml/yaml 7649d4548cb53a614db133b2a8ac1f31859dda8c
SRCREV_yaml.v2 = "7649d4548cb53a614db133b2a8ac1f31859dda8c"
SRC_URI += "git://github.com/go-yaml/yaml;name=yaml.v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/yaml.v2"

# [inet.af/tcpproxy v0.0.0-20200125044825-b6bb9b5b8252] git ls-remote https://github.com/inetaf/tcpproxy b6bb9b5b82524122bcf27291ede32d1517a14ab8
SRCREV_tcpproxy = "b6bb9b5b82524122bcf27291ede32d1517a14ab8"
SRC_URI += "git://github.com/inetaf/tcpproxy;name=tcpproxy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/inet.af/tcpproxy"

# [sigs.k8s.io/yaml v1.2.0] git ls-remote https://github.com/kubernetes-sigs/yaml 9fc95527decd95bb9d28cc2eab08179b2d0f6971
SRCREV_yaml = "9fc95527decd95bb9d28cc2eab08179b2d0f6971"
SRC_URI += "git://github.com/kubernetes-sigs/yaml;name=yaml;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/yaml"

# [github.com/lib/pq v1.10.2] git ls-remote https://github.com/lib/pq 2da6713d67f03911a05b1b6559adc85927fe076e
SRCREV_pq = "2da6713d67f03911a05b1b6559adc85927fe076e"
SRC_URI += "git://github.com/lib/pq;name=pq;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/lib/pq"

# [golang.org/x/crypto v0.0.0-20210220033148-5ea612d1eb83] git ls-remote https://go.googlesource.com/crypto 5ea612d1eb830b38bc4e914e37f55311eb58adce
SRCREV_crypto = "5ea612d1eb830b38bc4e914e37f55311eb58adce"
SRC_URI += "git://go.googlesource.com/crypto;name=crypto;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/crypto"

# [github.com/pkg/errors v0.9.1] git ls-remote https://github.com/pkg/errors 614d223910a179a466c1767a985424175c39b465
SRCREV_errors = "614d223910a179a466c1767a985424175c39b465"
SRC_URI += "git://github.com/pkg/errors;name=errors;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pkg/errors"

# [github.com/urfave/cli v1.22.4] git ls-remote https://github.com/urfave/cli 053ba9dd02d2bfb768da2c1c50370c59d41dc04b
SRCREV_cli = "053ba9dd02d2bfb768da2c1c50370c59d41dc04b"
SRC_URI += "git://github.com/urfave/cli;name=cli;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/urfave/cli"

# [github.com/google/uuid v1.3.0] git ls-remote https://github.com/google/uuid 44b5fee7c49cf3bcdf723f106b36d56ef13ccc88
SRCREV_uuid = "44b5fee7c49cf3bcdf723f106b36d56ef13ccc88"
SRC_URI += "git://github.com/google/uuid;name=uuid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/uuid"

# [github.com/gorilla/mux v1.8.0] git ls-remote https://github.com/gorilla/mux 98cb6bf42e086f6af920b965c38cacc07402d51b
SRCREV_mux = "98cb6bf42e086f6af920b965c38cacc07402d51b"
SRC_URI += "git://github.com/gorilla/mux;name=mux;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gorilla/mux"

# [github.com/k3s-io/kine v0.8.1] git ls-remote https://github.com/k3s-io/kine c1edece7772b4ff4f1f03f01d5218fbfe854c0cc
SRCREV_kine = "c1edece7772b4ff4f1f03f01d5218fbfe854c0cc"
SRC_URI += "git://github.com/k3s-io/kine;name=kine;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kine"

# [github.com/onsi/ginkgo v1.16.4] git ls-remote https://github.com/onsi/ginkgo d125cd027fee341b3b3d65858a4121cf4931fead
SRCREV_ginkgo = "d125cd027fee341b3b3d65858a4121cf4931fead"
SRC_URI += "git://github.com/onsi/ginkgo;name=ginkgo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/onsi/ginkgo"

# [github.com/onsi/gomega v1.11.0] git ls-remote https://github.com/onsi/gomega d9ee1e278b3bd59704a0521284ce8f8b25273b20
SRCREV_gomega = "d9ee1e278b3bd59704a0521284ce8f8b25273b20"
SRC_URI += "git://github.com/onsi/gomega;name=gomega;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/onsi/gomega"

# [github.com/spf13/pflag v1.0.5] git ls-remote https://github.com/spf13/pflag 2e9d26c8c37aae03e3f9d4e90b7116f5accb7cab
SRCREV_pflag = "2e9d26c8c37aae03e3f9d4e90b7116f5accb7cab"
SRC_URI += "git://github.com/spf13/pflag;name=pflag;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/spf13/pflag"

# [google.golang.org/grpc v1.38.0] git ls-remote https://github.com/grpc/grpc-go 0257c8657362b76f24e7a8cfb61df48d4cb735d3
SRCREV_grpc = "0257c8657362b76f24e7a8cfb61df48d4cb735d3"
SRC_URI += "git://github.com/grpc/grpc-go;name=grpc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/google.golang.org/grpc"

# [github.com/k3s-io/klog v1.0.0-k3s2] git ls-remote https://github.com/k3s-io/klog e94f416e9301d90f5c8d6043c999ea179bd9b455
SRCREV_klog = "e94f416e9301d90f5c8d6043c999ea179bd9b455"
SRC_URI += "git://github.com/k3s-io/klog;name=klog;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/klog"

# [github.com/otiai10/copy v1.6.0] git ls-remote https://github.com/otiai10/copy edeb9f37d4d0c28725014fcab6635120197932a1
SRCREV_copy = "edeb9f37d4d0c28725014fcab6635120197932a1"
SRC_URI += "git://github.com/otiai10/copy;name=copy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/otiai10/copy"

# [github.com/docker/docker v20.10.2+incompatible] git ls-remote https://github.com/moby/moby 8891c58a433a823ce0a65b57efff45f32ee9cb45
SRCREV_docker = "8891c58a433a823ce0a65b57efff45f32ee9cb45"
SRC_URI += "git://github.com/moby/moby;name=docker;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/docker"

# [github.com/rancher/lasso v0.0.0-20210616224652-fc3ebd901c08] git ls-remote https://github.com/rancher/lasso fc3ebd901c086dc8e4bfe2c07edf03c118572924
SRCREV_lasso = "fc3ebd901c086dc8e4bfe2c07edf03c118572924"
SRC_URI += "git://github.com/rancher/lasso;name=lasso;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/lasso"

# [github.com/robfig/cron/v3 v3.0.1] git ls-remote https://github.com/robfig/cron ccba498c397bb90a9c84945bbb0f7af2d72b6309
SRCREV_v3 = "ccba498c397bb90a9c84945bbb0f7af2d72b6309"
SRC_URI += "git://github.com/robfig/cron;name=v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/robfig/cron/v3"

# [github.com/k3s-io/klog/v2 v2.9.0-k3s2] git ls-remote https://github.com/k3s-io/klog 92394dadeec2079ad3102572fc8abf0a885cdae6
SRCREV_v2 = "92394dadeec2079ad3102572fc8abf0a885cdae6"
SRC_URI += "git://github.com/k3s-io/klog;name=v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/klog/v2"

# [github.com/google/cadvisor v0.39.3] git ls-remote https://github.com/google/cadvisor 899c56acc751a6055d22dca13e98418cea3c67b4
SRCREV_cadvisor = "899c56acc751a6055d22dca13e98418cea3c67b4"
SRC_URI += "git://github.com/google/cadvisor;name=cadvisor;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/cadvisor"

# [github.com/rancher/wharfie v0.5.1] git ls-remote https://github.com/rancher/wharfie 80cc0b0ce983af2d75be7846e006d69fa5d64570
SRCREV_wharfie = "80cc0b0ce983af2d75be7846e006d69fa5d64570"
SRC_URI += "git://github.com/rancher/wharfie;name=wharfie;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/wharfie"

# [github.com/sirupsen/logrus v1.8.1] git ls-remote https://github.com/sirupsen/logrus bdc0db8ead3853c56b7cd1ac2ba4e11b47d7da6b
SRCREV_logrus = "bdc0db8ead3853c56b7cd1ac2ba4e11b47d7da6b"
SRC_URI += "git://github.com/sirupsen/logrus;name=logrus;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/sirupsen/logrus"

# [github.com/k3s-io/cri-tools v1.21.0-k3s1] git ls-remote https://github.com/k3s-io/cri-tools 47c43d3b6f0254aec4746dbc747f2178f0188647
SRCREV_cri-tools = "47c43d3b6f0254aec4746dbc747f2178f0188647"
SRC_URI += "git://github.com/k3s-io/cri-tools;name=cri-tools;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/cri-tools"

# [github.com/mattn/go-sqlite3 v1.14.8] git ls-remote https://github.com/mattn/go-sqlite3 cba6eaee486f22a1b0f3208b145673ed951cb840
SRCREV_go-sqlite3 = "cba6eaee486f22a1b0f3208b145673ed951cb840"
SRC_URI += "git://github.com/mattn/go-sqlite3;name=go-sqlite3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mattn/go-sqlite3"

# [github.com/rancher/wrangler v0.8.10] git ls-remote https://github.com/rancher/wrangler 6970ad98ba7bd2755312ccfc6540a92bc9a9e316
SRCREV_wrangler = "6970ad98ba7bd2755312ccfc6540a92bc9a9e316"
SRC_URI += "git://github.com/rancher/wrangler;name=wrangler;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/wrangler"

# [github.com/stretchr/testify v1.7.0] git ls-remote https://github.com/stretchr/testify acba37e5db06f0093b465a7d47822bf13644b66c
SRCREV_testify = "acba37e5db06f0093b465a7d47822bf13644b66c"
SRC_URI += "git://github.com/stretchr/testify;name=testify;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/stretchr/testify"

# [github.com/Microsoft/hcsshim v0.8.20] git ls-remote https://github.com/microsoft/hcsshim 3ad51c76263bad09548a40e1996960814a12a870
SRCREV_hcsshim = "3ad51c76263bad09548a40e1996960814a12a870"
SRC_URI += "git://github.com/microsoft/hcsshim;name=hcsshim;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Microsoft/hcsshim"

# [github.com/k3s-io/containerd v1.5.9-k3s1] git ls-remote https://github.com/k3s-io/containerd d5a46d003e3079a0f4897fd97408409ab77b8e27
SRCREV_containerd = "d5a46d003e3079a0f4897fd97408409ab77b8e27"
SRC_URI += "git://github.com/k3s-io/containerd;name=containerd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/containerd"

# [github.com/coreos/go-systemd v0.0.0-20190321100706-95778dfbb74e] git ls-remote https://github.com/coreos/go-systemd 95778dfbb74eb7e4dbaf43bf7d71809650ef8076
SRCREV_go-systemd = "95778dfbb74eb7e4dbaf43bf7d71809650ef8076"
SRC_URI += "git://github.com/coreos/go-systemd;name=go-systemd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/go-systemd"

# [github.com/gorilla/websocket v1.4.2] git ls-remote https://github.com/gorilla/websocket b65e62901fc1c0d968042419e74789f6af455eb9
SRCREV_websocket = "b65e62901fc1c0d968042419e74789f6af455eb9"
SRC_URI += "git://github.com/gorilla/websocket;name=websocket;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gorilla/websocket"

# [github.com/minio/minio-go/v7 v7.0.7] git ls-remote https://github.com/minio/minio-go 40d41266f363962b9243529b3a042bb453c1f4c6
SRCREV_v7 = "40d41266f363962b9243529b3a042bb453c1f4c6"
SRC_URI += "git://github.com/minio/minio-go;name=v7;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/minio/minio-go/v7"

# [github.com/tchap/go-patricia v2.3.0+incompatible] git ls-remote https://github.com/tchap/go-patricia a7f0089c6f496e8e70402f61733606daa326cac5
SRCREV_go-patricia = "a7f0089c6f496e8e70402f61733606daa326cac5"
SRC_URI += "git://github.com/tchap/go-patricia;name=go-patricia;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/tchap/go-patricia"

# [github.com/k3s-io/kubernetes v1.22.6-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 4ffc33b0cfb40b12ee1c687503491d9e17009928
SRCREV_kubernetes = "4ffc33b0cfb40b12ee1c687503491d9e17009928"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=kubernetes;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes"

# [github.com/containerd/cgroups v1.0.1] git ls-remote https://github.com/containerd/cgroups b9de8a2212026c07cec67baf3323f1fc0121e048
SRCREV_cgroups = "b9de8a2212026c07cec67baf3323f1fc0121e048"
SRC_URI += "git://github.com/containerd/cgroups;name=cgroups;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/cgroups"

# [github.com/coreos/go-iptables v0.5.0] git ls-remote https://github.com/coreos/go-iptables abea47c2ca57b2fa33a189f63a63b0269eec487a
SRCREV_go-iptables = "abea47c2ca57b2fa33a189f63a63b0269eec487a"
SRC_URI += "git://github.com/coreos/go-iptables;name=go-iptables;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/go-iptables"

# [github.com/flannel-io/flannel v0.15.1] git ls-remote https://github.com/flannel-io/flannel f0f9b5262b993c4800726cb5d59f6da3b8a3dc4e
SRCREV_flannel = "f0f9b5262b993c4800726cb5d59f6da3b8a3dc4e"
SRC_URI += "git://github.com/flannel-io/flannel;name=flannel;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/flannel-io/flannel"

# [github.com/golangplus/testing v1.0.0] git ls-remote https://github.com/golangplus/testing d51138b619a0cd6d297e1a9985accd95ca75be46
SRCREV_testing = "d51138b619a0cd6d297e1a9985accd95ca75be46"
SRC_URI += "git://github.com/golangplus/testing;name=testing;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golangplus/testing"

# [github.com/klauspost/compress v1.13.6] git ls-remote https://github.com/klauspost/compress 38d4ba985ac157cb858763e016645e14e74c13c4
SRCREV_compress = "38d4ba985ac157cb858763e016645e14e74c13c4"
SRC_URI += "git://github.com/klauspost/compress;name=compress;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/klauspost/compress"

# [github.com/k3s-io/etcd/api/v3 v3.5.1-k3s1] git ls-remote https://github.com/k3s-io/etcd 643f36c2206cf25c8103cccc4a5e036092ee51d0
SRCREV_api-v3 = "643f36c2206cf25c8103cccc4a5e036092ee51d0"
SRC_URI += "git://github.com/k3s-io/etcd;name=api-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/api/v3"

# [github.com/erikdubbelboer/gspt v0.0.0-20190125194910-e68493906b83] git ls-remote https://github.com/erikdubbelboer/gspt e68493906b8382891943ddc9960cb9c6ecd1a1f0
SRCREV_gspt = "e68493906b8382891943ddc9960cb9c6ecd1a1f0"
SRC_URI += "git://github.com/erikdubbelboer/gspt;name=gspt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/erikdubbelboer/gspt"

# [github.com/go-sql-driver/mysql v1.6.0] git ls-remote https://github.com/go-sql-driver/mysql bcc459a906419e2890a50fc2c99ea6dd927a88f2
SRCREV_mysql = "bcc459a906419e2890a50fc2c99ea6dd927a88f2"
SRC_URI += "git://github.com/go-sql-driver/mysql;name=mysql;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-sql-driver/mysql"

# [github.com/opencontainers/runc v1.0.3] git ls-remote https://github.com/opencontainers/runc f46b6ba2c9314cfc8caae24a32ec5fe9ef1059fe
SRCREV_runc = "f46b6ba2c9314cfc8caae24a32ec5fe9ef1059fe"
SRC_URI += "git://github.com/opencontainers/runc;name=runc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opencontainers/runc"

# [github.com/natefinch/lumberjack v2.0.0+incompatible] git ls-remote https://github.com/natefinch/lumberjack 7d6a1875575e09256dc552b4c0e450dcd02bd10e
SRCREV_lumberjack = "7d6a1875575e09256dc552b4c0e450dcd02bd10e"
SRC_URI += "git://github.com/natefinch/lumberjack;name=lumberjack;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/natefinch/lumberjack"

# [github.com/rancher/remotedialer v0.2.0] git ls-remote https://github.com/rancher/remotedialer 3d086baa0d95326b73f6f1d16286cc04fc856790
SRCREV_remotedialer = "3d086baa0d95326b73f6f1d16286cc04fc856790"
SRC_URI += "git://github.com/rancher/remotedialer;name=remotedialer;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/remotedialer"

# [github.com/go-bindata/go-bindata v3.1.2+incompatible] git ls-remote https://github.com/go-bindata/go-bindata ff7109080027ec152dabb369e157c4f359b76f31
SRCREV_go-bindata = "ff7109080027ec152dabb369e157c4f359b76f31"
SRC_URI += "git://github.com/go-bindata/go-bindata;name=go-bindata;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-bindata/go-bindata"

# [github.com/k3s-io/etcd/client/v3 v3.5.1-k3s1] git ls-remote https://github.com/k3s-io/etcd 643f36c2206cf25c8103cccc4a5e036092ee51d0
SRCREV_client-v3 = "643f36c2206cf25c8103cccc4a5e036092ee51d0"
SRC_URI += "git://github.com/k3s-io/etcd;name=client-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/client/v3"

# [github.com/k3s-io/etcd/server/v3 v3.5.1-k3s1] git ls-remote https://github.com/k3s-io/etcd 643f36c2206cf25c8103cccc4a5e036092ee51d0
SRCREV_server-v3 = "643f36c2206cf25c8103cccc4a5e036092ee51d0"
SRC_URI += "git://github.com/k3s-io/etcd;name=server-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/server/v3"

# [github.com/k3s-io/helm-controller v0.11.7] git ls-remote https://github.com/k3s-io/helm-controller f8b5a878922bd9a9eb5a9e8e65a3552cf90ed2c4
SRCREV_helm-controller = "f8b5a878922bd9a9eb5a9e8e65a3552cf90ed2c4"
SRC_URI += "git://github.com/k3s-io/helm-controller;name=helm-controller;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/helm-controller"

# [github.com/opencontainers/selinux v1.8.2] git ls-remote https://github.com/opencontainers/selinux 76bc82e11d854d3e40c08889d13c98abcea72ea2
SRCREV_selinux = "76bc82e11d854d3e40c08889d13c98abcea72ea2"
SRC_URI += "git://github.com/opencontainers/selinux;name=selinux;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opencontainers/selinux"

# [github.com/k3s-io/etcd/etcdutl/v3 v3.5.1-k3s1] git ls-remote https://github.com/k3s-io/etcd 643f36c2206cf25c8103cccc4a5e036092ee51d0
SRCREV_etcdutl-v3 = "643f36c2206cf25c8103cccc4a5e036092ee51d0"
SRC_URI += "git://github.com/k3s-io/etcd;name=etcdutl-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/etcdutl/v3"

# [github.com/rancher/dynamiclistener v0.3.1] git ls-remote https://github.com/rancher/dynamiclistener 43f9c3ae0a4fe7e689b2e2ed5a7064ed01ad8e64
SRCREV_dynamiclistener = "43f9c3ae0a4fe7e689b2e2ed5a7064ed01ad8e64"
SRC_URI += "git://github.com/rancher/dynamiclistener;name=dynamiclistener;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/dynamiclistener"

# [github.com/containerd/stargz-snapshotter v0.10.1] git ls-remote https://github.com/containerd/stargz-snapshotter 91eb38acd4102d9e08edc3f583f7c18c6e614971
SRCREV_stargz-snapshotter = "91eb38acd4102d9e08edc3f583f7c18c6e614971"
SRC_URI += "git://github.com/containerd/stargz-snapshotter;name=stargz-snapshotter;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/stargz-snapshotter"

# [github.com/rootless-containers/rootlesskit v0.14.5] git ls-remote https://github.com/rootless-containers/rootlesskit 1216988f0e4f48a70ce849a8f690352aaeae8c13
SRCREV_rootlesskit = "1216988f0e4f48a70ce849a8f690352aaeae8c13"
SRC_URI += "git://github.com/rootless-containers/rootlesskit;name=rootlesskit;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rootless-containers/rootlesskit"

# [github.com/containerd/fuse-overlayfs-snapshotter v1.0.4] git ls-remote https://github.com/containerd/fuse-overlayfs-snapshotter db90194f0cf2f42ee8cdc3c542f6ed2c92ef8ffc
SRCREV_fuse-overlayfs-snapshotter = "db90194f0cf2f42ee8cdc3c542f6ed2c92ef8ffc"
SRC_URI += "git://github.com/containerd/fuse-overlayfs-snapshotter;name=fuse-overlayfs-snapshotter;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/fuse-overlayfs-snapshotter"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/api v1.22.6-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 4ffc33b0cfb40b12ee1c687503491d9e17009928
SRCREV_api = "4ffc33b0cfb40b12ee1c687503491d9e17009928"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=api;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/api"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/cri-api v1.22.6-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 4ffc33b0cfb40b12ee1c687503491d9e17009928
SRCREV_cri-api = "4ffc33b0cfb40b12ee1c687503491d9e17009928"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=cri-api;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/cri-api"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/kubectl v1.22.6-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 4ffc33b0cfb40b12ee1c687503491d9e17009928
SRCREV_kubectl = "4ffc33b0cfb40b12ee1c687503491d9e17009928"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=kubectl;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/kubectl"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/apiserver v1.22.6-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 4ffc33b0cfb40b12ee1c687503491d9e17009928
SRCREV_apiserver = "4ffc33b0cfb40b12ee1c687503491d9e17009928"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=apiserver;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/apiserver"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/client-go v1.22.6-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 4ffc33b0cfb40b12ee1c687503491d9e17009928
SRCREV_client-go = "4ffc33b0cfb40b12ee1c687503491d9e17009928"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=client-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/client-go"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/apimachinery v1.22.6-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 4ffc33b0cfb40b12ee1c687503491d9e17009928
SRCREV_apimachinery = "4ffc33b0cfb40b12ee1c687503491d9e17009928"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=apimachinery;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/apimachinery"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/cloud-provider v1.22.6-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 4ffc33b0cfb40b12ee1c687503491d9e17009928
SRCREV_cloud-provider = "4ffc33b0cfb40b12ee1c687503491d9e17009928"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=cloud-provider;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/cloud-provider"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/code-generator v1.22.6-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 4ffc33b0cfb40b12ee1c687503491d9e17009928
SRCREV_code-generator = "4ffc33b0cfb40b12ee1c687503491d9e17009928"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=code-generator;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/code-generator"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/component-base v1.22.6-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 4ffc33b0cfb40b12ee1c687503491d9e17009928
SRCREV_component-base = "4ffc33b0cfb40b12ee1c687503491d9e17009928"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=component-base;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/component-base"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/controller-manager v1.22.6-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 4ffc33b0cfb40b12ee1c687503491d9e17009928
SRCREV_controller-manager = "4ffc33b0cfb40b12ee1c687503491d9e17009928"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=controller-manager;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/controller-manager"

