# [k8s.io/utils v0.0.0-20240102154912-e7106e64919e] git ls-remote https://github.com/kubernetes/utils e7106e64919e62d73c0926352134656a22dc2e38
SRCREV_utils = "e7106e64919e62d73c0926352134656a22dc2e38"
SRC_URI += "git://github.com/kubernetes/utils;name=utils;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/k8s.io/utils"

# [k8s.io/gengo v0.0.0-20220902162205-c0856e24416d] git ls-remote https://github.com/kubernetes/gengo c0856e24416daea2775735ff996a5870c2033839
SRCREV_gengo = "c0856e24416daea2775735ff996a5870c2033839"
SRC_URI += "git://github.com/kubernetes/gengo;name=gengo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/k8s.io/gengo"

# [go.uber.org/fx v1.20.1] git ls-remote https://github.com/uber-go/fx 9636854c6fc588f0ca497000ac18f858f8083ebd
SRCREV_fx = "9636854c6fc588f0ca497000ac18f858f8083ebd"
SRC_URI += "git://github.com/uber-go/fx;name=fx;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.uber.org/fx"

# [go.uber.org/zap v1.27.0] git ls-remote https://github.com/uber-go/zap fcf8ee58669e358bbd6460bef5c2ee7a53c0803a
SRCREV_zap = "fcf8ee58669e358bbd6460bef5c2ee7a53c0803a"
SRC_URI += "git://github.com/uber-go/zap;name=zap;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.uber.org/zap"

# [dario.cat/mergo v1.0.0] git ls-remote https://github.com/imdario/mergo 131de815afc35a77c41ae99da6c8f4288b6cb513
SRCREV_mergo = "131de815afc35a77c41ae99da6c8f4288b6cb513"
SRC_URI += "git://github.com/imdario/mergo;name=mergo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/dario.cat/mergo"

# [go.starlark.net v0.0.0-20200306205701-8dd3e2ee1dd5] git ls-remote https://github.com/google/starlark-go 8dd3e2ee1dd5d034baada4c7b4fcf231294a1013
SRCREV_go.starlark.net = "8dd3e2ee1dd5d034baada4c7b4fcf231294a1013"
SRC_URI += "git://github.com/google/starlark-go;name=go.starlark.net;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.starlark.net"

# [go.uber.org/dig v1.17.1] git ls-remote https://github.com/uber-go/dig 3c7d5e3878b76b0a709514e395597059b6490fb5
SRCREV_dig = "3c7d5e3878b76b0a709514e395597059b6490fb5"
SRC_URI += "git://github.com/uber-go/dig;name=dig;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.uber.org/dig"

# [gopkg.in/inf.v0 v0.9.1] git ls-remote https://github.com/go-inf/inf d2d2541c53f18d2a059457998ce2876cc8e67cbf
SRCREV_inf.v0 = "d2d2541c53f18d2a059457998ce2876cc8e67cbf"
SRC_URI += "git://github.com/go-inf/inf;name=inf.v0;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/inf.v0"

# [gopkg.in/ini.v1 v1.67.0] git ls-remote https://github.com/go-ini/ini b2f570e5b5b844226bbefe6fb521d891f529a951
SRCREV_ini.v1 = "b2f570e5b5b844226bbefe6fb521d891f529a951"
SRC_URI += "git://github.com/go-ini/ini;name=ini.v1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/ini.v1"

# [golang.org/x/net v0.17.0] git ls-remote https://go.googlesource.com/net b225e7ca6dde1ef5a5ae5ce922861bda011cfabd
SRCREV_net = "b225e7ca6dde1ef5a5ae5ce922861bda011cfabd"
SRC_URI += "git://go.googlesource.com/net;name=net;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/net"

# [golang.org/x/sys v0.18.0] git ls-remote https://go.googlesource.com/sys 360f961f8978a4c9a7c2e849bb482780cd6bb553
SRCREV_sys = "360f961f8978a4c9a7c2e849bb482780cd6bb553"
SRC_URI += "git://go.googlesource.com/sys;name=sys;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/sys"

# [gopkg.in/yaml.v2 v2.4.0] git ls-remote https://github.com/go-yaml/yaml 7649d4548cb53a614db133b2a8ac1f31859dda8c
SRCREV_yaml.v2 = "7649d4548cb53a614db133b2a8ac1f31859dda8c"
SRC_URI += "git://github.com/go-yaml/yaml;name=yaml.v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/yaml.v2"

# [inet.af/tcpproxy v0.0.0-20200125044825-b6bb9b5b8252] git ls-remote https://github.com/inetaf/tcpproxy b6bb9b5b82524122bcf27291ede32d1517a14ab8
SRCREV_tcpproxy = "b6bb9b5b82524122bcf27291ede32d1517a14ab8"
SRC_URI += "git://github.com/inetaf/tcpproxy;name=tcpproxy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/inet.af/tcpproxy"

# [sigs.k8s.io/yaml v1.4.0] git ls-remote https://github.com/kubernetes-sigs/yaml c3772b51db126345efe2dfe4ff8dac83b8141684
SRCREV_yaml = "c3772b51db126345efe2dfe4ff8dac83b8141684"
SRC_URI += "git://github.com/kubernetes-sigs/yaml;name=yaml;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/yaml"

# [go.etcd.io/bbolt v1.3.9] git ls-remote https://github.com/etcd-io/bbolt 50aef2646b0fd58bd395530de7940f2609efdb2b
SRCREV_bbolt = "50aef2646b0fd58bd395530de7940f2609efdb2b"
SRC_URI += "git://github.com/etcd-io/bbolt;name=bbolt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.etcd.io/bbolt"

# [go.opencensus.io v0.24.0] git ls-remote https://github.com/census-instrumentation/opencensus-go b1a01ee95db0e690d91d7193d037447816fae4c5
SRCREV_go.opencensus.io = "b1a01ee95db0e690d91d7193d037447816fae4c5"
SRC_URI += "git://github.com/census-instrumentation/opencensus-go;name=go.opencensus.io;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opencensus.io"

# [go.uber.org/mock v0.4.0] git ls-remote https://github.com/uber/mock 74a29c6e6c2cbb8ccee94db061c1604ff33fd188
SRCREV_go.uber.org-mock = "74a29c6e6c2cbb8ccee94db061c1604ff33fd188"
SRC_URI += "git://github.com/uber/mock;name=go.uber.org-mock;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.uber.org/mock"

# [golang.org/x/exp v0.0.0-20240222234643-814bf88cf225] git ls-remote https://go.googlesource.com/exp 814bf88cf225cd422a50435865fb5b9f55b7e59e
SRCREV_exp = "814bf88cf225cd422a50435865fb5b9f55b7e59e"
SRC_URI += "git://go.googlesource.com/exp;name=exp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/exp"

# [golang.org/x/mod v0.15.0] git ls-remote https://go.googlesource.com/mod fa1ba4269bda724bb9f01ec381fbbaf031e45833
SRCREV_mod = "fa1ba4269bda724bb9f01ec381fbbaf031e45833"
SRC_URI += "git://go.googlesource.com/mod;name=mod;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/mod"

# [gopkg.in/gcfg.v1 v1.2.3] git ls-remote https://github.com/go-gcfg/gcfg 61b2c08bc8f6068f7c5ca684372f9a6cb1c45ebe
SRCREV_gcfg.v1 = "61b2c08bc8f6068f7c5ca684372f9a6cb1c45ebe"
SRC_URI += "git://github.com/go-gcfg/gcfg;name=gcfg.v1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/gcfg.v1"

# [gopkg.in/yaml.v3 v3.0.1] git ls-remote https://github.com/go-yaml/yaml f6f7691b1fdeb513f56608cd2c32c51f8194bf51
SRCREV_yaml.v3 = "f6f7691b1fdeb513f56608cd2c32c51f8194bf51"
SRC_URI += "git://github.com/go-yaml/yaml;name=yaml.v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/yaml.v3"

# [sigs.k8s.io/json v0.0.0-20221116044647-bc3834ca7abd] git ls-remote https://github.com/kubernetes-sigs/json bc3834ca7abd3a90f03ef00a27ad80cb892f9c21
SRCREV_json = "bc3834ca7abd3a90f03ef00a27ad80cb892f9c21"
SRC_URI += "git://github.com/kubernetes-sigs/json;name=json;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/json"

# [github.com/lib/pq v1.10.2] git ls-remote https://github.com/lib/pq 2da6713d67f03911a05b1b6559adc85927fe076e
SRCREV_pq = "2da6713d67f03911a05b1b6559adc85927fe076e"
SRC_URI += "git://github.com/lib/pq;name=pq;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/lib/pq"

# [golang.org/x/sync v0.7.0] git ls-remote https://go.googlesource.com/sync 14be23e5b48bec28285f8a694875175ecacfddb3
SRCREV_sync = "14be23e5b48bec28285f8a694875175ecacfddb3"
SRC_URI += "git://go.googlesource.com/sync;name=sync;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/sync"

# [github.com/rs/xid v1.5.0] git ls-remote https://github.com/rs/xid 47a0ac1e0b750ee1f43718be223bb07601c66a1f
SRCREV_xid = "47a0ac1e0b750ee1f43718be223bb07601c66a1f"
SRC_URI += "git://github.com/rs/xid;name=xid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rs/xid"

# [golang.org/x/term v0.19.0] git ls-remote https://go.googlesource.com/term 5b15d269ba1f54e8da86c8aa5574253aea0c2198
SRCREV_x-term = "5b15d269ba1f54e8da86c8aa5574253aea0c2198"
SRC_URI += "git://go.googlesource.com/term;name=x-term;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/term"

# [golang.org/x/text v0.14.0] git ls-remote https://go.googlesource.com/text 6c97a165dd661335ff7bce6104a008558123c353
SRCREV_text = "6c97a165dd661335ff7bce6104a008558123c353"
SRC_URI += "git://go.googlesource.com/text;name=text;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/text"

# [golang.org/x/time v0.5.0] git ls-remote https://go.googlesource.com/time 883aed519795b30de35e6bc28ec8f681494afa87
SRCREV_time = "883aed519795b30de35e6bc28ec8f681494afa87"
SRC_URI += "git://go.googlesource.com/time;name=time;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/time"

# [golang.org/x/tools v0.18.0] git ls-remote https://go.googlesource.com/tools c5643e9baf7fed6936d70e3abf925f86fa895ca1
SRCREV_tools = "c5643e9baf7fed6936d70e3abf925f86fa895ca1"
SRC_URI += "git://go.googlesource.com/tools;name=tools;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/tools"

# [gonum.org/v1/gonum v0.13.0] git ls-remote https://github.com/gonum/gonum 91a06ac64c4b32c929427846d4d1d3b8202ad7b1
SRCREV_gonum = "91a06ac64c4b32c929427846d4d1d3b8202ad7b1"
SRC_URI += "git://github.com/gonum/gonum;name=gonum;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gonum.org/v1/gonum"

# [golang.org/x/crypto v0.14.0] git ls-remote https://go.googlesource.com/crypto e3cc52e598e302f8c613a645bb7231264d8ec995
SRCREV_crypto = "e3cc52e598e302f8c613a645bb7231264d8ec995"
SRC_URI += "git://go.googlesource.com/crypto;name=crypto;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/crypto"

# [golang.org/x/oauth2 v0.17.0] git ls-remote https://go.googlesource.com/oauth2 ebe81ad83719fe3426335b22e40a1e3a76fa45c0
SRCREV_oauth2 = "ebe81ad83719fe3426335b22e40a1e3a76fa45c0"
SRC_URI += "git://go.googlesource.com/oauth2;name=oauth2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/oauth2"

# [k8s.io/kube-openapi v0.0.0-20230501164219-8b0f38b5fd1f] git ls-remote https://github.com/kubernetes/kube-openapi 8b0f38b5fd1f5300d4275b3f886e267124a57c58
SRCREV_kube-openapi = "8b0f38b5fd1f5300d4275b3f886e267124a57c58"
SRC_URI += "git://github.com/kubernetes/kube-openapi;name=kube-openapi;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/k8s.io/kube-openapi"

# [github.com/ipfs/boxo v0.10.0] git ls-remote https://github.com/ipfs/boxo 6f82d77995476b0d85722539230a50a321706ead
SRCREV_boxo = "6f82d77995476b0d85722539230a50a321706ead"
SRC_URI += "git://github.com/ipfs/boxo;name=boxo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ipfs/boxo"

# [github.com/miekg/dns v1.1.58] git ls-remote https://github.com/miekg/dns a493770824062dc616b70e7cd004b890f9e7b702
SRCREV_dns = "a493770824062dc616b70e7cd004b890f9e7b702"
SRC_URI += "git://github.com/miekg/dns;name=dns;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/miekg/dns"

# [github.com/moby/ipvs v1.1.0] git ls-remote https://github.com/moby/ipvs fe22ac585b3e22a969cbde61addd99ecd93ab22c
SRCREV_ipvs = "fe22ac585b3e22a969cbde61addd99ecd93ab22c"
SRC_URI += "git://github.com/moby/ipvs;name=ipvs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/ipvs"

# [github.com/moby/term v0.0.0-20221205130635-1aeaba878587] git ls-remote https://github.com/moby/term 1aeaba8785877a66f57739be9fccb6f5cfab429e
SRCREV_term = "1aeaba8785877a66f57739be9fccb6f5cfab429e"
SRC_URI += "git://github.com/moby/term;name=term;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/term"

# [go.mozilla.org/pkcs7 v0.0.0-20200128120323-432b2356ecb1] git ls-remote https://github.com/mozilla-services/pkcs7 432b2356ecb18209c1cec25680b8a23632794f21
SRCREV_pkcs7 = "432b2356ecb18209c1cec25680b8a23632794f21"
SRC_URI += "git://github.com/mozilla-services/pkcs7;name=pkcs7;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.mozilla.org/pkcs7"

# [go.uber.org/multierr v1.11.0] git ls-remote https://github.com/uber-go/multierr de75ae527b39a27afcb50a84427ec7b84021d5f4
SRCREV_multierr = "de75ae527b39a27afcb50a84427ec7b84021d5f4"
SRC_URI += "git://github.com/uber-go/multierr;name=multierr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.uber.org/multierr"

# [gopkg.in/warnings.v0 v0.1.1] git ls-remote https://github.com/go-warnings/warnings 8a331561fe74dadba6edfc59f3be66c22c3b065d
SRCREV_warnings.v0 = "8a331561fe74dadba6edfc59f3be66c22c3b065d"
SRC_URI += "git://github.com/go-warnings/warnings;name=warnings.v0;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/warnings.v0"

# [github.com/pkg/errors v0.9.1] git ls-remote https://github.com/pkg/errors 614d223910a179a466c1767a985424175c39b465
SRCREV_errors = "614d223910a179a466c1767a985424175c39b465"
SRC_URI += "git://github.com/pkg/errors;name=errors;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pkg/errors"

# [github.com/urfave/cli v1.22.14] git ls-remote https://github.com/urfave/cli f5ca62f301d773bdc9c800aa0e24aec82ad01a1d
SRCREV_cli = "f5ca62f301d773bdc9c800aa0e24aec82ad01a1d"
SRC_URI += "git://github.com/urfave/cli;name=cli;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/urfave/cli"

# [github.com/docker/cli v24.0.7+incompatible] git ls-remote https://github.com/docker/cli afdd53b4e341be38d2056a42113b938559bb1d94
SRCREV_docker-cli = "afdd53b4e341be38d2056a42113b938559bb1d94"
SRC_URI += "git://github.com/docker/cli;name=docker-cli;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/cli"

# [github.com/gofrs/uuid v4.0.0+incompatible] git ls-remote https://github.com/gofrs/uuid 4b36aa0ea796d49630bbae624f8f05ab7013af77
SRCREV_gofrs-uuid = "4b36aa0ea796d49630bbae624f8f05ab7013af77"
SRC_URI += "git://github.com/gofrs/uuid;name=gofrs-uuid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gofrs/uuid"

# [google.golang.org/api v0.60.0] git ls-remote https://github.com/googleapis/google-api-go-client ccca5aa6d9d9aba8ad11c879ccea89c94663ea39
SRCREV_google.golang.org-api = "ccca5aa6d9d9aba8ad11c879ccea89c94663ea39"
SRC_URI += "git://github.com/googleapis/google-api-go-client;name=google.golang.org-api;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/google.golang.org/api"

# [github.com/golang/mock v1.6.0] git ls-remote https://github.com/golang/mock aba2ff9a6844d5e3289e8472d3217d5b3090f083
SRCREV_mock = "aba2ff9a6844d5e3289e8472d3217d5b3090f083"
SRC_URI += "git://github.com/golang/mock;name=mock;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golang/mock"

# [github.com/google/uuid v1.6.0] git ls-remote https://github.com/google/uuid 0f11ee6918f41a04c201eceeadf612a377bc7fbc
SRCREV_uuid = "0f11ee6918f41a04c201eceeadf612a377bc7fbc"
SRC_URI += "git://github.com/google/uuid;name=uuid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/uuid"

# [github.com/gorilla/mux v1.8.1] git ls-remote https://github.com/gorilla/mux b4617d0b9670ad14039b2739167fd35a60f557c5
SRCREV_mux = "b4617d0b9670ad14039b2739167fd35a60f557c5"
SRC_URI += "git://github.com/gorilla/mux;name=mux;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gorilla/mux"

# [github.com/k3s-io/kine v0.11.9] git ls-remote https://github.com/k3s-io/kine edd8f35371395a3b0c4ea229061f46807855bed7
SRCREV_kine = "edd8f35371395a3b0c4ea229061f46807855bed7"
SRC_URI += "git://github.com/k3s-io/kine;name=kine;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kine"

# [github.com/onsi/gomega v1.32.0] git ls-remote https://github.com/onsi/gomega 437995126acee58e6237f963913f54cb6386dd0a
SRCREV_gomega = "437995126acee58e6237f963913f54cb6386dd0a"
SRC_URI += "git://github.com/onsi/gomega;name=gomega;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/onsi/gomega"

# [github.com/k3s-io/runc v1.1.12-k3s1] git ls-remote https://github.com/k3s-io/runc 7d07dac287da807a624adba7ea7ccc1b3f28c614
SRCREV_runc = "7d07dac287da807a624adba7ea7ccc1b3f28c614"
SRC_URI += "git://github.com/k3s-io/runc;name=runc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/runc"

# [github.com/spf13/pflag v1.0.5] git ls-remote https://github.com/spf13/pflag 2e9d26c8c37aae03e3f9d4e90b7116f5accb7cab
SRCREV_pflag = "2e9d26c8c37aae03e3f9d4e90b7116f5accb7cab"
SRC_URI += "git://github.com/spf13/pflag;name=pflag;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/spf13/pflag"

# [google.golang.org/grpc v1.58.3] git ls-remote https://github.com/grpc/grpc-go bf05b9558c16677e362d231120f8213eb276d406
SRCREV_grpc = "bf05b9558c16677e362d231120f8213eb276d406"
SRC_URI += "git://github.com/grpc/grpc-go;name=grpc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/google.golang.org/grpc"

# [github.com/cilium/ebpf v0.9.1] git ls-remote https://github.com/cilium/ebpf d560e4479b395c4523851a4571b04ba0b3846cd1
SRCREV_ebpf = "d560e4479b395c4523851a4571b04ba0b3846cd1"
SRC_URI += "git://github.com/cilium/ebpf;name=ebpf;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cilium/ebpf"

# [github.com/flynn/noise v1.1.0] git ls-remote https://github.com/flynn/noise 4d9f71cd4ba1fe81415efac312664ccc4bc79b46
SRCREV_noise = "4d9f71cd4ba1fe81415efac312664ccc4bc79b46"
SRC_URI += "git://github.com/flynn/noise;name=noise;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/flynn/noise"

# [github.com/ghodss/yaml v1.0.0] git ls-remote https://github.com/ghodss/yaml 0ca9ea5df5451ffdf184b4428c902747c2c11cd7
SRCREV_ghodss-yaml = "0ca9ea5df5451ffdf184b4428c902747c2c11cd7"
SRC_URI += "git://github.com/ghodss/yaml;name=ghodss-yaml;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ghodss/yaml"

# [github.com/gofrs/flock v0.8.1] git ls-remote https://github.com/gofrs/flock 6f010d1acea74a32f2f2066bfe324c08bbee30e3
SRCREV_flock = "6f010d1acea74a32f2f2066bfe324c08bbee30e3"
SRC_URI += "git://github.com/gofrs/flock;name=flock;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gofrs/flock"

# [github.com/huin/goupnp v1.3.0] git ls-remote https://github.com/huin/goupnp 00783e79ec6092ce7c16ab10ef62e92e75e89939
SRCREV_goupnp = "00783e79ec6092ce7c16ab10ef62e92e75e89939"
SRC_URI += "git://github.com/huin/goupnp;name=goupnp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/huin/goupnp"

# [github.com/ipfs/go-cid v0.4.1] git ls-remote https://github.com/ipfs/go-cid d46e7f28669cd2c463bc68fe86e7dbe4f8240ab7
SRCREV_go-cid = "d46e7f28669cd2c463bc68fe86e7dbe4f8240ab7"
SRC_URI += "git://github.com/ipfs/go-cid;name=go-cid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ipfs/go-cid"

# [github.com/ipfs/go-log v1.0.5] git ls-remote https://github.com/ipfs/go-log c39ee80c0915c5cca41dc1311e848c2fd7fa4101
SRCREV_go-log = "c39ee80c0915c5cca41dc1311e848c2fd7fa4101"
SRC_URI += "git://github.com/ipfs/go-log;name=go-log;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ipfs/go-log"

# [github.com/moby/locker v1.0.1] git ls-remote https://github.com/moby/locker 281af2d563954745bea9d1487c965f24d30742fe
SRCREV_locker = "281af2d563954745bea9d1487c965f24d30742fe"
SRC_URI += "git://github.com/moby/locker;name=locker;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/locker"

# [github.com/pierrec/lz4 v2.6.0+incompatible] git ls-remote https://github.com/pierrec/lz4 0e583d326e0ec6b9c1ad223188dc709af385408e
SRCREV_lz4 = "0e583d326e0ec6b9c1ad223188dc709af385408e"
SRC_URI += "git://github.com/pierrec/lz4;name=lz4;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pierrec/lz4"

# [github.com/spf13/afero v1.11.0] git ls-remote https://github.com/spf13/afero 5c4385aa20510dba5ca4db12c02b0c9211d82892
SRCREV_afero = "5c4385aa20510dba5ca4db12c02b0c9211d82892"
SRC_URI += "git://github.com/spf13/afero;name=afero;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/spf13/afero"

# [github.com/spf13/cobra v1.8.0] git ls-remote https://github.com/spf13/cobra a0a6ae020bb3899ff0276067863e50523f897370
SRCREV_cobra = "a0a6ae020bb3899ff0276067863e50523f897370"
SRC_URI += "git://github.com/spf13/cobra;name=cobra;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/spf13/cobra"

# [github.com/go-logr/logr v1.4.1] git ls-remote https://github.com/go-logr/logr dcdc3f2cd12e8a5c4e2a6712d6958c90e2e5bd98
SRCREV_logr = "dcdc3f2cd12e8a5c4e2a6712d6958c90e2e5bd98"
SRC_URI += "git://github.com/go-logr/logr;name=logr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-logr/logr"

# [github.com/go-logr/stdr v1.2.3-0.20220714215716-96bad1d688c5] git ls-remote https://github.com/go-logr/stdr 96bad1d688c524409b0da98c82fb7d3d51e60639
SRCREV_stdr = "96bad1d688c524409b0da98c82fb7d3d51e60639"
SRC_URI += "git://github.com/go-logr/stdr;name=stdr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-logr/stdr"

# [github.com/go-test/deep v1.0.7] git ls-remote https://github.com/go-test/deep c733f5ed5136b7437e29ac91bb97c653af3694b5
SRCREV_deep = "c733f5ed5136b7437e29ac91bb97c653af3694b5"
SRC_URI += "git://github.com/go-test/deep;name=deep;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-test/deep"

# [github.com/otiai10/copy v1.7.0] git ls-remote https://github.com/otiai10/copy 323db161ae97db91e6e13dbcda403fdb29c3fff8
SRCREV_copy = "323db161ae97db91e6e13dbcda403fdb29c3fff8"
SRC_URI += "git://github.com/otiai10/copy;name=copy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/otiai10/copy"

# [github.com/Rican7/retry v0.1.0] git ls-remote https://github.com/Rican7/retry 28d17f812805614e76f170aa3c8698155ea8e019
SRCREV_retry = "28d17f812805614e76f170aa3c8698155ea8e019"
SRC_URI += "git://github.com/Rican7/retry;name=retry;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Rican7/retry"

# [github.com/beorn7/perks v1.0.1] git ls-remote https://github.com/beorn7/perks 37c8de3658fcb183f997c4e13e8337516ab753e6
SRCREV_perks = "37c8de3658fcb183f997c4e13e8337516ab753e6"
SRC_URI += "git://github.com/beorn7/perks;name=perks;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/beorn7/perks"

# [github.com/blang/semver v3.5.1+incompatible] git ls-remote https://github.com/blang/semver 2ee87856327ba09384cabd113bc6b5d174e9ec0f
SRCREV_semver = "2ee87856327ba09384cabd113bc6b5d174e9ec0f"
SRC_URI += "git://github.com/blang/semver;name=semver;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/blang/semver"

# [github.com/google/btree v1.1.2] git ls-remote https://github.com/google/btree 8e29150ba321eef204059de2ab494f179b6cff2c
SRCREV_btree = "8e29150ba321eef204059de2ab494f179b6cff2c"
SRC_URI += "git://github.com/google/btree;name=btree;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/btree"

# [github.com/google/pprof v0.0.0-20240207164012-fb44976bdcd5] git ls-remote https://github.com/google/pprof fb44976bdcd59b48559fb1763d69313508ad3a75
SRCREV_pprof = "fb44976bdcd59b48559fb1763d69313508ad3a75"
SRC_URI += "git://github.com/google/pprof;name=pprof;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/pprof"

# [github.com/google/shlex v0.0.0-20191202100458-e7afc7fbc510] git ls-remote https://github.com/google/shlex e7afc7fbc51079733e9468cdfd1efcd7d196cd1d
SRCREV_shlex = "e7afc7fbc51079733e9468cdfd1efcd7d196cd1d"
SRC_URI += "git://github.com/google/shlex;name=shlex;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/shlex"

# [github.com/jackc/pgx/v5 v5.5.4] git ls-remote https://github.com/jackc/pgx da6f2c98f2664b215b40b1606551fdfcc7f3ea5c
SRCREV_pgx-v5 = "da6f2c98f2664b215b40b1606551fdfcc7f3ea5c"
SRC_URI += "git://github.com/jackc/pgx;name=pgx-v5;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jackc/pgx/v5"

# [github.com/miekg/pkcs11 v1.1.1] git ls-remote https://github.com/miekg/pkcs11 f3481918a208bd212aa995a41f92d786eb418a7d
SRCREV_pkcs11 = "f3481918a208bd212aa995a41f92d786eb418a7d"
SRC_URI += "git://github.com/miekg/pkcs11;name=pkcs11;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/miekg/pkcs11"

# [github.com/morikuni/aec v1.0.0] git ls-remote https://github.com/morikuni/aec 39771216ff4c63d11f5e604076f9c45e8be1067b
SRCREV_aec = "39771216ff4c63d11f5e604076f9c45e8be1067b"
SRC_URI += "git://github.com/morikuni/aec;name=aec;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/morikuni/aec"

# [github.com/nats-io/nuid v1.0.1] git ls-remote https://github.com/nats-io/nuid 4b96681fa6d28dd0ab5fe79bac63b3a493d9ee94
SRCREV_nuid = "4b96681fa6d28dd0ab5fe79bac63b3a493d9ee94"
SRC_URI += "git://github.com/nats-io/nuid;name=nuid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/nats-io/nuid"

# [lukechampine.com/blake3 v1.2.1] git ls-remote https://github.com/lukechampine/blake3 6e4325968f64ca24b1bbc8fbf08ea320d17ebfa0
SRCREV_blake3 = "6e4325968f64ca24b1bbc8fbf08ea320d17ebfa0"
SRC_URI += "git://github.com/lukechampine/blake3;name=blake3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/lukechampine.com/blake3"

# [github.com/docker/docker v24.0.8+incompatible] git ls-remote https://github.com/moby/moby 61c51fbb5aeb648eb5f97704b8c75be3ccf1c9a0
SRCREV_docker = "61c51fbb5aeb648eb5f97704b8c75be3ccf1c9a0"
SRC_URI += "git://github.com/moby/moby;name=docker;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/docker"

# [github.com/joho/godotenv v1.5.1] git ls-remote https://github.com/joho/godotenv 3fc4292b58a67b78e1dbb6e47b4879a6cc602ec4
SRCREV_godotenv = "3fc4292b58a67b78e1dbb6e47b4879a6cc602ec4"
SRC_URI += "git://github.com/joho/godotenv;name=godotenv;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/joho/godotenv"

# [github.com/rancher/lasso v0.0.0-20230830164424-d684fdeb6f29] git ls-remote https://github.com/rancher/lasso d684fdeb6f29e221289c6f59fdc390b6adbaaccf
SRCREV_lasso = "d684fdeb6f29e221289c6f59fdc390b6adbaaccf"
SRC_URI += "git://github.com/rancher/lasso;name=lasso;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/lasso"

# [github.com/k3s-io/spegel v0.0.23-0.20240516234953-f3d2c4072314] git ls-remote https://github.com/k3s-io/spegel f3d2c40723149dcefc9b219dddc5bdd44cff0874
SRCREV_spegel = "f3d2c40723149dcefc9b219dddc5bdd44cff0874"
SRC_URI += "git://github.com/k3s-io/spegel;name=spegel;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/spegel"

# [github.com/armon/circbuf v0.0.0-20150827004946-bbbad097214e] git ls-remote https://github.com/armon/circbuf bbbad097214e2918d8543d5201d12bfd7bca254d
SRCREV_circbuf = "bbbad097214e2918d8543d5201d12bfd7bca254d"
SRC_URI += "git://github.com/armon/circbuf;name=circbuf;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/armon/circbuf"

# [github.com/goccy/go-json v0.10.2] git ls-remote https://github.com/goccy/go-json 8e8cdeacf2f2faef082f32848138f0f9af7cfb66
SRCREV_go-json = "8e8cdeacf2f2faef082f32848138f0f9af7cfb66"
SRC_URI += "git://github.com/goccy/go-json;name=go-json;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/goccy/go-json"

# [github.com/gogo/protobuf v1.3.2] git ls-remote https://github.com/gogo/protobuf b03c65ea87cdc3521ede29f62fe3ce239267c1bc
SRCREV_protobuf = "b03c65ea87cdc3521ede29f62fe3ce239267c1bc"
SRC_URI += "git://github.com/gogo/protobuf;name=protobuf;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gogo/protobuf"

# [github.com/golang/snappy v0.0.4] git ls-remote https://github.com/golang/snappy 544b4180ac705b7605231d4a4550a1acb22a19fe
SRCREV_snappy = "544b4180ac705b7605231d4a4550a1acb22a19fe"
SRC_URI += "git://github.com/golang/snappy;name=snappy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golang/snappy"

# [github.com/google/cel-go v0.12.7] git ls-remote https://github.com/google/cel-go 4be7081b9ce97ccc03102242e6d8d7f65d49d2cd
SRCREV_cel-go = "4be7081b9ce97ccc03102242e6d8d7f65d49d2cd"
SRC_URI += "git://github.com/google/cel-go;name=cel-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/cel-go"

# [github.com/google/go-cmp v0.6.0] git ls-remote https://github.com/google/go-cmp c3ad8435e7bef96af35732bc0789e5a2278c6d5f
SRCREV_go-cmp = "c3ad8435e7bef96af35732bc0789e5a2278c6d5f"
SRC_URI += "git://github.com/google/go-cmp;name=go-cmp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/go-cmp"

# [github.com/google/gofuzz v1.2.0] git ls-remote https://github.com/google/gofuzz 379e164120fbc98885a8f494b5aa41ba94f64c56
SRCREV_gofuzz = "379e164120fbc98885a8f494b5aa41ba94f64c56"
SRC_URI += "git://github.com/google/gofuzz;name=gofuzz;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/gofuzz"

# [github.com/imdario/mergo v0.3.16] git ls-remote https://github.com/darccio/mergo 14fe2b165b83359196f820886a2b24f2771729e9
SRCREV_imdario-mergo = "14fe2b165b83359196f820886a2b24f2771729e9"
SRC_URI += "git://github.com/darccio/mergo;name=imdario-mergo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/imdario/mergo"

# [github.com/koron/go-ssdp v0.0.4] git ls-remote https://github.com/koron/go-ssdp 615e2904c24d115f20139e60b9ab5916b1dfd55d
SRCREV_go-ssdp = "615e2904c24d115f20139e60b9ab5916b1dfd55d"
SRC_URI += "git://github.com/koron/go-ssdp;name=go-ssdp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/koron/go-ssdp"

# [github.com/libp2p/go-nat v0.2.0] git ls-remote https://github.com/libp2p/go-nat 14ce74b6949ca4d3f4889568e20840bdf0b05009
SRCREV_go-nat = "14ce74b6949ca4d3f4889568e20840bdf0b05009"
SRC_URI += "git://github.com/libp2p/go-nat;name=go-nat;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-nat"

# [github.com/mikioh/tcpopt v0.0.0-20190314235656-172688c1accc] git ls-remote https://github.com/mikioh/tcpopt 172688c1accceb1c8699343c22838f55e4b662ca
SRCREV_tcpopt = "172688c1accceb1c8699343c22838f55e4b662ca"
SRC_URI += "git://github.com/mikioh/tcpopt;name=tcpopt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mikioh/tcpopt"

# [github.com/moby/sys/user v0.1.0] git ls-remote https://github.com/moby/sys c0711cde08c8fa33857a2c28721659267f49b5e2
SRCREV_user = "c0711cde08c8fa33857a2c28721659267f49b5e2"
SRC_URI += "git://github.com/moby/sys;name=user;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/sys/user"

# [github.com/nats-io/nkeys v0.4.7] git ls-remote https://github.com/nats-io/nkeys c865baf4058b0ae6529eeb82fbe86bd8c21f4a36
SRCREV_nkeys = "c865baf4058b0ae6529eeb82fbe86bd8c21f4a36"
SRC_URI += "git://github.com/nats-io/nkeys;name=nkeys;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/nats-io/nkeys"

# [github.com/pbnjay/memory v0.0.0-20210728143218-7b4eea64cf58] git ls-remote https://github.com/pbnjay/memory 7b4eea64cf580186c0eceb10dc94ba3a098af46c
SRCREV_memory = "7b4eea64cf580186c0eceb10dc94ba3a098af46c"
SRC_URI += "git://github.com/pbnjay/memory;name=memory;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pbnjay/memory"

# [github.com/quic-go/qpack v0.4.0] git ls-remote https://github.com/quic-go/qpack 3e7287cc7ce655141583b8511fbe09800d4ba896
SRCREV_qpack = "3e7287cc7ce655141583b8511fbe09800d4ba896"
SRC_URI += "git://github.com/quic-go/qpack;name=qpack;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/quic-go/qpack"

# [github.com/soheilhy/cmux v0.1.5] git ls-remote https://github.com/soheilhy/cmux 5ec6847320e53b5fee0ab9a4757b56625a946c85
SRCREV_cmux = "5ec6847320e53b5fee0ab9a4757b56625a946c85"
SRC_URI += "git://github.com/soheilhy/cmux;name=cmux;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/soheilhy/cmux"

# [github.com/tidwall/btree v1.6.0] git ls-remote https://github.com/tidwall/btree c538c0ce1d47ebada0c423fd430978ba274d7d68
SRCREV_tidwall-btree = "c538c0ce1d47ebada0c423fd430978ba274d7d68"
SRC_URI += "git://github.com/tidwall/btree;name=tidwall-btree;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/tidwall/btree"

# [github.com/urfave/cli/v2 v2.23.5] git ls-remote https://github.com/urfave/cli 600ef6e4dd5db1819a8eb0b453487bf1c0e59099
SRCREV_cli-v2 = "600ef6e4dd5db1819a8eb0b453487bf1c0e59099"
SRC_URI += "git://github.com/urfave/cli;name=cli-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/urfave/cli/v2"

# [go.opentelemetry.io/otel v1.13.0] git ls-remote https://github.com/open-telemetry/opentelemetry-go f2fd476f433128c2494476950ce11600a51bbe35
SRCREV_otel = "f2fd476f433128c2494476950ce11600a51bbe35"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-go;name=otel;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/otel"

# [github.com/containerd/zfs v1.1.0] git ls-remote https://github.com/containerd/zfs 26134297cde4138b412644d6819c20b105472991
SRCREV_zfs = "26134297cde4138b412644d6819c20b105472991"
SRC_URI += "git://github.com/containerd/zfs;name=zfs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/zfs"

# [github.com/ipfs/go-log/v2 v2.5.1] git ls-remote https://github.com/ipfs/go-log 8625e3ec81bdeb96627de192e6fe21eab5896603
SRCREV_go-log-v2 = "8625e3ec81bdeb96627de192e6fe21eab5896603"
SRC_URI += "git://github.com/ipfs/go-log;name=go-log-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ipfs/go-log/v2"

# [github.com/onsi/ginkgo/v2 v2.16.0] git ls-remote https://github.com/onsi/ginkgo a181ee22f50186b1be81d3d3011a6841518782d2
SRCREV_ginkgo-v2 = "a181ee22f50186b1be81d3d3011a6841518782d2"
SRC_URI += "git://github.com/onsi/ginkgo;name=ginkgo-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/onsi/ginkgo/v2"

# [github.com/robfig/cron/v3 v3.0.1] git ls-remote https://github.com/robfig/cron ccba498c397bb90a9c84945bbb0f7af2d72b6309
SRCREV_cron-v3 = "ccba498c397bb90a9c84945bbb0f7af2d72b6309"
SRC_URI += "git://github.com/robfig/cron;name=cron-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/robfig/cron/v3"

# [github.com/k3s-io/klog/v2 v2.90.1-k3s1] git ls-remote https://github.com/k3s-io/klog 79c569094edd4a7ca048d9b9b1e47edc6b22e7c6
SRCREV_klog-v2 = "79c569094edd4a7ca048d9b9b1e47edc6b22e7c6"
SRC_URI += "git://github.com/k3s-io/klog;name=klog-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/klog/v2"

# [github.com/containerd/log v0.1.0] git ls-remote https://github.com/containerd/log 0fc1e28871fdf2786e2cc51bbe4133db6547a199
SRCREV_log = "0fc1e28871fdf2786e2cc51bbe4133db6547a199"
SRC_URI += "git://github.com/containerd/log;name=log;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/log"

# [github.com/containerd/nri v0.6.1] git ls-remote https://github.com/containerd/nri fa64d110ed4a77eae5ea2e46ea2d3991e02f0789
SRCREV_nri = "fa64d110ed4a77eae5ea2e46ea2d3991e02f0789"
SRC_URI += "git://github.com/containerd/nri;name=nri;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/nri"

# [github.com/coreos/go-oidc v2.1.0+incompatible] git ls-remote https://github.com/coreos/go-oidc 2be1c5b8a260760503f66dc0996e102b683b3ac3
SRCREV_go-oidc = "2be1c5b8a260760503f66dc0996e102b683b3ac3"
SRC_URI += "git://github.com/coreos/go-oidc;name=go-oidc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/go-oidc"

# [github.com/godbus/dbus/v5 v5.1.0] git ls-remote https://github.com/godbus/dbus e523abc905595cf17fb0001a7d77eaaddfaa216d
SRCREV_dbus-v5 = "e523abc905595cf17fb0001a7d77eaaddfaa216d"
SRC_URI += "git://github.com/godbus/dbus;name=dbus-v5;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/godbus/dbus/v5"

# [github.com/google/gnostic v0.7.0] git ls-remote https://github.com/google/gnostic ee84fd2a96205f519ad7b86d989673d2ada03a3b
SRCREV_gnostic = "ee84fd2a96205f519ad7b86d989673d2ada03a3b"
SRC_URI += "git://github.com/google/gnostic;name=gnostic;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/gnostic"

# [github.com/mikioh/tcpinfo v0.0.0-20190314235526-30a79bb1804b] git ls-remote https://github.com/mikioh/tcpinfo 30a79bb1804bc47fa7fe29928c9109f368792a9e
SRCREV_tcpinfo = "30a79bb1804bc47fa7fe29928c9109f368792a9e"
SRC_URI += "git://github.com/mikioh/tcpinfo;name=tcpinfo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mikioh/tcpinfo"

# [github.com/minio/md5-simd v1.1.2] git ls-remote https://github.com/minio/md5-simd 776275e0c9a74ceebbd50fe5c1d61b0c80c608df
SRCREV_md5-simd = "776275e0c9a74ceebbd50fe5c1d61b0c80c608df"
SRC_URI += "git://github.com/minio/md5-simd;name=md5-simd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/minio/md5-simd"

# [github.com/mohae/deepcopy v0.0.0-20170929034955-c48cc78d4826] git ls-remote https://github.com/mohae/deepcopy c48cc78d482608239f6c4c92a4abd87eb8761c90
SRCREV_deepcopy = "c48cc78d482608239f6c4c92a4abd87eb8761c90"
SRC_URI += "git://github.com/mohae/deepcopy;name=deepcopy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mohae/deepcopy"

# [github.com/mr-tron/base58 v1.2.0] git ls-remote https://github.com/mr-tron/base58 cd0e5141f51dfcadb8311fd8e495eb11126a8010
SRCREV_base58 = "cd0e5141f51dfcadb8311fd8e495eb11126a8010"
SRC_URI += "git://github.com/mr-tron/base58;name=base58;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mr-tron/base58"

# [github.com/nats-io/jsm.go v0.0.31-0.20220317133147-fe318f464eee] git ls-remote https://github.com/nats-io/jsm.go fe318f464eee9ceef6120ea851e5cf94a0497ac6
SRCREV_jsm.go = "fe318f464eee9ceef6120ea851e5cf94a0497ac6"
SRC_URI += "git://github.com/nats-io/jsm.go;name=jsm.go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/nats-io/jsm.go"

# [github.com/nats-io/jwt/v2 v2.5.5] git ls-remote https://github.com/nats-io/jwt c2d30e2ffc632a1ea64030467e5a40e02e4158be
SRCREV_jwt-v2 = "c2d30e2ffc632a1ea64030467e5a40e02e4158be"
SRC_URI += "git://github.com/nats-io/jwt;name=jwt-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/nats-io/jwt/v2"

# [github.com/polydawn/refmt v0.89.0] git ls-remote https://github.com/polydawn/refmt ad1efcb83999082a4ec5ac34b9d5c08bc388faf3
SRCREV_refmt = "ad1efcb83999082a4ec5ac34b9d5c08bc388faf3"
SRC_URI += "git://github.com/polydawn/refmt;name=refmt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/polydawn/refmt"

# [github.com/rubiojr/go-vhd v0.0.0-20200706105327-02e210299021] git ls-remote https://github.com/rubiojr/go-vhd 02e2102990218160c1cb608a3e9679312a3b8425
SRCREV_go-vhd = "02e2102990218160c1cb608a3e9679312a3b8425"
SRC_URI += "git://github.com/rubiojr/go-vhd;name=go-vhd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rubiojr/go-vhd"

# [github.com/vmware/govmomi v0.30.6] git ls-remote https://github.com/vmware/govmomi 55614148d1fe0df8ac8e04174ffd2344e374adb8
SRCREV_govmomi = "55614148d1fe0df8ac8e04174ffd2344e374adb8"
SRC_URI += "git://github.com/vmware/govmomi;name=govmomi;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/vmware/govmomi"

# [github.com/xlab/treeprint v1.1.0] git ls-remote https://github.com/xlab/treeprint 31541c3fc088ae2b344370e3b1141f999ef3d03a
SRCREV_treeprint = "31541c3fc088ae2b344370e3b1141f999ef3d03a"
SRC_URI += "git://github.com/xlab/treeprint;name=treeprint;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/xlab/treeprint"

# [github.com/xrash/smetrics v0.0.0-20201216005158-039620a65673] git ls-remote https://github.com/xrash/smetrics 039620a656736e6ad994090895784a7af15e0b80
SRCREV_smetrics = "039620a656736e6ad994090895784a7af15e0b80"
SRC_URI += "git://github.com/xrash/smetrics;name=smetrics;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/xrash/smetrics"

# [sigs.k8s.io/kustomize/api v0.13.2] git ls-remote https://github.com/kubernetes-sigs/kustomize efe13749409367df57fa5c488885afebe1eabd6a
SRCREV_kustomize-api = "efe13749409367df57fa5c488885afebe1eabd6a"
SRC_URI += "git://github.com/kubernetes-sigs/kustomize;name=kustomize-api;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/kustomize/api"

# [github.com/containerd/aufs v1.0.0] git ls-remote https://github.com/containerd/aufs fb0192dcb2c0bbfce3bd8756fc88026870c0354d
SRCREV_aufs = "fb0192dcb2c0bbfce3bd8756fc88026870c0354d"
SRC_URI += "git://github.com/containerd/aufs;name=aufs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/aufs"

# [github.com/google/cadvisor v0.47.2] git ls-remote https://github.com/google/cadvisor 6730be153c6b6cfc1a8782496b5c24ec2dfc0f56
SRCREV_cadvisor = "6730be153c6b6cfc1a8782496b5c24ec2dfc0f56"
SRC_URI += "git://github.com/google/cadvisor;name=cadvisor;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/cadvisor"

# [github.com/rancher/wharfie v0.5.3] git ls-remote https://github.com/rancher/wharfie 3ede7b88d327b06884f70978da9e87a0a210c6b3
SRCREV_wharfie = "3ede7b88d327b06884f70978da9e87a0a210c6b3"
SRC_URI += "git://github.com/rancher/wharfie;name=wharfie;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/wharfie"

# [github.com/sirupsen/logrus v1.9.3] git ls-remote https://github.com/sirupsen/logrus d40e25cd45ed9c6b2b66e6b97573a0413e4c23bd
SRCREV_logrus = "d40e25cd45ed9c6b2b66e6b97573a0413e4c23bd"
SRC_URI += "git://github.com/sirupsen/logrus;name=logrus;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/sirupsen/logrus"

# [github.com/blang/semver/v4 v4.0.0] git ls-remote https://github.com/blang/semver af3461a9cbcf1f3f5889d21b83f5ef63880c33a8
SRCREV_semver-v4 = "af3461a9cbcf1f3f5889d21b83f5ef63880c33a8"
SRC_URI += "git://github.com/blang/semver;name=semver-v4;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/blang/semver/v4"

# [github.com/containerd/fifo v1.1.0] git ls-remote https://github.com/containerd/fifo 151b205263c29d471e0d55c787d2ce9f5343fd46
SRCREV_fifo = "151b205263c29d471e0d55c787d2ce9f5343fd46"
SRC_URI += "git://github.com/containerd/fifo;name=fifo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/fifo"

# [github.com/davecgh/go-spew v1.1.2-0.20180830191138-d8f796af33cc] git ls-remote https://github.com/davecgh/go-spew d8f796af33cc11cb798c1aaeb27a4ebc5099927d
SRCREV_go-spew = "d8f796af33cc11cb798c1aaeb27a4ebc5099927d"
SRC_URI += "git://github.com/davecgh/go-spew;name=go-spew;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/davecgh/go-spew"

# [github.com/docker/go-units v0.5.0] git ls-remote https://github.com/docker/go-units e682442797b36348f8e1f98defdbf32bac0b6c6f
SRCREV_go-units = "e682442797b36348f8e1f98defdbf32bac0b6c6f"
SRC_URI += "git://github.com/docker/go-units;name=go-units;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/go-units"

# [github.com/elastic/gosigar v0.14.2] git ls-remote https://github.com/elastic/gosigar 9d6c92629470099edd40ead9a3d8cf1b38020ec6
SRCREV_gosigar = "9d6c92629470099edd40ead9a3d8cf1b38020ec6"
SRC_URI += "git://github.com/elastic/gosigar;name=gosigar;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/elastic/gosigar"

# [github.com/fatih/camelcase v1.0.0] git ls-remote https://github.com/fatih/camelcase 44e46d280b43ec1531bb25252440e34f1b800b65
SRCREV_camelcase = "44e46d280b43ec1531bb25252440e34f1b800b65"
SRC_URI += "git://github.com/fatih/camelcase;name=camelcase;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/fatih/camelcase"

# [github.com/go-openapi/swag v0.22.9] git ls-remote https://github.com/go-openapi/swag a05020e2eba35111df9afd1d3186792050a6a876
SRCREV_swag = "a05020e2eba35111df9afd1d3186792050a6a876"
SRC_URI += "git://github.com/go-openapi/swag;name=swag;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/swag"

# [github.com/golang/protobuf v1.5.4] git ls-remote https://github.com/golang/protobuf 75de7c059e36b64f01d0dd234ff2fff404ec3374
SRCREV_golang-protobuf = "75de7c059e36b64f01d0dd234ff2fff404ec3374"
SRC_URI += "git://github.com/golang/protobuf;name=golang-protobuf;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golang/protobuf"

# [github.com/google/gopacket v1.1.19] git ls-remote https://github.com/google/gopacket a9779d139771f6a06fc983b18e0efd23ca30222f
SRCREV_gopacket = "a9779d139771f6a06fc983b18e0efd23ca30222f"
SRC_URI += "git://github.com/google/gopacket;name=gopacket;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/gopacket"

# [github.com/intel/goresctrl v0.3.0] git ls-remote https://github.com/intel/goresctrl c40cbba82c8e94fe89926174efc817586bb3950a
SRCREV_goresctrl = "c40cbba82c8e94fe89926174efc817586bb3950a"
SRC_URI += "git://github.com/intel/goresctrl;name=goresctrl;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/intel/goresctrl"

# [github.com/jackc/pgerrcode v0.0.0-20220416144525-469b46aa5efa] git ls-remote https://github.com/jackc/pgerrcode 469b46aa5efae8a229646096c4d7026bf9ff89fe
SRCREV_pgerrcode = "469b46aa5efae8a229646096c4d7026bf9ff89fe"
SRC_URI += "git://github.com/jackc/pgerrcode;name=pgerrcode;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jackc/pgerrcode"

# [github.com/jackc/puddle/v2 v2.2.1] git ls-remote https://github.com/jackc/puddle 825ae07315635013021d71e1c2cac71c367f2902
SRCREV_puddle-v2 = "825ae07315635013021d71e1c2cac71c367f2902"
SRC_URI += "git://github.com/jackc/puddle;name=puddle-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jackc/puddle/v2"

# [github.com/libp2p/go-msgio v0.3.0] git ls-remote https://github.com/libp2p/go-msgio 12f8f7a72c7dbbb246151e4c98b5a6d59e27e0c6
SRCREV_go-msgio = "12f8f7a72c7dbbb246151e4c98b5a6d59e27e0c6"
SRC_URI += "git://github.com/libp2p/go-msgio;name=go-msgio;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-msgio"

# [github.com/mailru/easyjson v0.7.7] git ls-remote https://github.com/mailru/easyjson c120ca7ced6051261161ce15e8f1542a4b2567fc
SRCREV_easyjson = "c120ca7ced6051261161ce15e8f1542a4b2567fc"
SRC_URI += "git://github.com/mailru/easyjson;name=easyjson;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mailru/easyjson"

# [github.com/mattn/go-isatty v0.0.20] git ls-remote https://github.com/mattn/go-isatty a7c02353c47bc4ec6b30dc9628154ae4fe760c11
SRCREV_go-isatty = "a7c02353c47bc4ec6b30dc9628154ae4fe760c11"
SRC_URI += "git://github.com/mattn/go-isatty;name=go-isatty;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mattn/go-isatty"

# [github.com/mdlayher/socket v0.4.1] git ls-remote https://github.com/mdlayher/socket 024cdfb30ba417ac6f1b27bb5189a8099787dcf7
SRCREV_socket = "024cdfb30ba417ac6f1b27bb5189a8099787dcf7"
SRC_URI += "git://github.com/mdlayher/socket;name=socket;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mdlayher/socket"

# [github.com/moby/spdystream v0.2.0] git ls-remote https://github.com/moby/spdystream dbc715126c0e3fa07721879c6d265b2b82c71e5b
SRCREV_spdystream = "dbc715126c0e3fa07721879c6d265b2b82c71e5b"
SRC_URI += "git://github.com/moby/spdystream;name=spdystream;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/spdystream"

# [github.com/moby/sys/signal v0.7.0] git ls-remote https://github.com/moby/sys b8d8fabf1fa5cf0de7c1a1729145eee854ea31f5
SRCREV_signal = "b8d8fabf1fa5cf0de7c1a1729145eee854ea31f5"
SRC_URI += "git://github.com/moby/sys;name=signal;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/sys/signal"

# [github.com/mxk/go-flowrate v0.0.0-20140419014527-cca7078d478f] git ls-remote https://github.com/mxk/go-flowrate cca7078d478f8520f85629ad7c68962d31ed7682
SRCREV_go-flowrate = "cca7078d478f8520f85629ad7c68962d31ed7682"
SRC_URI += "git://github.com/mxk/go-flowrate;name=go-flowrate;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mxk/go-flowrate"

# [github.com/nats-io/nats.go v1.34.0] git ls-remote https://github.com/nats-io/nats.go 33316cdf884166bf6231192fa88304bb6533367c
SRCREV_nats.go = "33316cdf884166bf6231192fa88304bb6533367c"
SRC_URI += "git://github.com/nats-io/nats.go;name=nats.go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/nats-io/nats.go"

# [github.com/quic-go/quic-go v0.42.0] git ls-remote https://github.com/quic-go/quic-go 4a99b816ae3ab03ae5449d15aac45147c85ed47a
SRCREV_quic-go = "4a99b816ae3ab03ae5449d15aac45147c85ed47a"
SRC_URI += "git://github.com/quic-go/quic-go;name=quic-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/quic-go/quic-go"

# [github.com/xiang90/probing v0.0.0-20221125231312-a49e3df8f510] git ls-remote https://github.com/xiang90/probing a49e3df8f510ee8b42e68345ca4636dbb161bd0a
SRCREV_probing = "a49e3df8f510ee8b42e68345ca4636dbb161bd0a"
SRC_URI += "git://github.com/xiang90/probing;name=probing;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/xiang90/probing"

# [golang.zx2c4.com/wireguard v0.0.0-20230325221338-052af4a8072b] git ls-remote https://git.zx2c4.com/wireguard-go 052af4a8072bbbd3bfe7edf46fe3c1b350f71f08
SRCREV_wireguard = "052af4a8072bbbd3bfe7edf46fe3c1b350f71f08"
SRC_URI += "git://git.zx2c4.com/wireguard-go;name=wireguard;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.zx2c4.com/wireguard"

# [google.golang.org/genproto v0.0.0-20220502173005-c8bf987b8c21] git ls-remote https://github.com/googleapis/go-genproto c8bf987b8c21778beffccfd5a923546432c2d250
SRCREV_genproto = "c8bf987b8c21778beffccfd5a923546432c2d250"
SRC_URI += "git://github.com/googleapis/go-genproto;name=genproto;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/google.golang.org/genproto"

# [google.golang.org/protobuf v1.33.0] git ls-remote https://github.com/protocolbuffers/protobuf-go ec47fd138f9221b19a2afd6570b3c39ede9df3dc
SRCREV_google.golang.org-protobuf = "ec47fd138f9221b19a2afd6570b3c39ede9df3dc"
SRC_URI += "git://github.com/protocolbuffers/protobuf-go;name=google.golang.org-protobuf;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/google.golang.org/protobuf"

# [gopkg.in/square/go-jose.v2 v2.6.0] git ls-remote https://github.com/square/go-jose a10ff54e00bc6e833bf549e04ae976f0fe8ea2fd
SRCREV_go-jose.v2 = "a10ff54e00bc6e833bf549e04ae976f0fe8ea2fd"
SRC_URI += "git://github.com/square/go-jose;name=go-jose.v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/square/go-jose.v2"

# [github.com/json-iterator/go v1.1.12] git ls-remote https://github.com/json-iterator/go 024077e996b048517130b21ea6bf12aa23055d3d
SRCREV_go = "024077e996b048517130b21ea6bf12aa23055d3d"
SRC_URI += "git://github.com/json-iterator/go;name=go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/json-iterator/go"

# [github.com/k3s-io/cri-tools v1.26.0-rc.0-k3s1] git ls-remote https://github.com/k3s-io/cri-tools 029d9bbf8bfb43c46a80b013cb6bf163739df0c8
SRCREV_cri-tools = "029d9bbf8bfb43c46a80b013cb6bf163739df0c8"
SRC_URI += "git://github.com/k3s-io/cri-tools;name=cri-tools;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/cri-tools"

# [github.com/libp2p/go-libp2p v0.33.2] git ls-remote https://github.com/libp2p/go-libp2p fccfbe7a4b6841325100038b83f86cd4e097b9a1
SRCREV_go-libp2p = "fccfbe7a4b6841325100038b83f86cd4e097b9a1"
SRC_URI += "git://github.com/libp2p/go-libp2p;name=go-libp2p;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-libp2p"

# [github.com/mattn/go-sqlite3 v1.14.19] git ls-remote https://github.com/mattn/go-sqlite3 00b02e0ba98effd5f157d39216e244af8a807f9b
SRCREV_go-sqlite3 = "00b02e0ba98effd5f157d39216e244af8a807f9b"
SRC_URI += "git://github.com/mattn/go-sqlite3;name=go-sqlite3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mattn/go-sqlite3"

# [github.com/rancher/wrangler v1.1.1-0.20230807182002-35cb42e6a915] git ls-remote https://github.com/rancher/wrangler 35cb42e6a915f38753a99cdb1c5eaa7102af0a9c
SRCREV_wrangler = "35cb42e6a915f38753a99cdb1c5eaa7102af0a9c"
SRC_URI += "git://github.com/rancher/wrangler;name=wrangler;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/wrangler"

# [github.com/stretchr/testify v1.9.0] git ls-remote https://github.com/stretchr/testify bb548d0473d4e1c9b7bbfd6602c7bf12f7a84dd2
SRCREV_testify = "bb548d0473d4e1c9b7bbfd6602c7bf12f7a84dd2"
SRC_URI += "git://github.com/stretchr/testify;name=testify;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/stretchr/testify"

# [cloud.google.com/go/compute v1.23.3] git ls-remote https://github.com/googleapis/google-cloud-go 2ba47cb7adfef32617eb11888331ccc2d2a0f84d
SRCREV_compute = "2ba47cb7adfef32617eb11888331ccc2d2a0f84d"
SRC_URI += "git://github.com/googleapis/google-cloud-go;name=compute;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/cloud.google.com/go/compute"

# [github.com/containerd/ttrpc v1.2.4] git ls-remote https://github.com/containerd/ttrpc 196dbef62845f9e02f2492a4d4b7e977d4347e33
SRCREV_ttrpc = "196dbef62845f9e02f2492a4d4b7e977d4347e33"
SRC_URI += "git://github.com/containerd/ttrpc;name=ttrpc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/ttrpc"

# [github.com/coreos/go-semver v0.3.0] git ls-remote https://github.com/coreos/go-semver e214231b295a8ea9479f11b70b35d5acf3556d9b
SRCREV_go-semver = "e214231b295a8ea9479f11b70b35d5acf3556d9b"
SRC_URI += "git://github.com/coreos/go-semver;name=go-semver;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/go-semver"

# [github.com/docker/go-events v0.0.0-20190806004212-e31b211e4f1c] git ls-remote https://github.com/docker/go-events e31b211e4f1cd09aa76fe4ac244571fab96ae47f
SRCREV_go-events = "e31b211e4f1cd09aa76fe4ac244571fab96ae47f"
SRC_URI += "git://github.com/docker/go-events;name=go-events;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/go-events"

# [github.com/go-errors/errors v1.4.2] git ls-remote https://github.com/go-errors/errors 33d496f939bc762321a636d4035e15c302eb0b00
SRCREV_go-errors-errors = "33d496f939bc762321a636d4035e15c302eb0b00"
SRC_URI += "git://github.com/go-errors/errors;name=go-errors-errors;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-errors/errors"

# [github.com/jackc/pgpassfile v1.0.0] git ls-remote https://github.com/jackc/pgpassfile 99d8e8e28945ffceaf75b0299fcb2bb656b8a683
SRCREV_pgpassfile = "99d8e8e28945ffceaf75b0299fcb2bb656b8a683"
SRC_URI += "git://github.com/jackc/pgpassfile;name=pgpassfile;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jackc/pgpassfile"

# [github.com/jbenet/goprocess v0.1.4] git ls-remote https://github.com/jbenet/goprocess 23d20c20149e1f362afda26f4500cb9d6393f0ad
SRCREV_goprocess = "23d20c20149e1f362afda26f4500cb9d6393f0ad"
SRC_URI += "git://github.com/jbenet/goprocess;name=goprocess;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jbenet/goprocess"

# [github.com/josharian/intern v1.0.0] git ls-remote https://github.com/josharian/intern 8e6ff32b3e7c0b018c43953085fe2ac330fe9acd
SRCREV_intern = "8e6ff32b3e7c0b018c43953085fe2ac330fe9acd"
SRC_URI += "git://github.com/josharian/intern;name=intern;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/josharian/intern"

# [github.com/josharian/native v1.1.0] git ls-remote https://github.com/josharian/native c1e37c09b531b14ae12a501eb6fd529b31cecdaa
SRCREV_native = "c1e37c09b531b14ae12a501eb6fd529b31cecdaa"
SRC_URI += "git://github.com/josharian/native;name=native;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/josharian/native"

# [github.com/lithammer/dedent v1.1.0] git ls-remote https://github.com/lithammer/dedent 8478954c3bc893cf36c5ee7c822266b993a3b3ee
SRCREV_dedent = "8478954c3bc893cf36c5ee7c822266b993a3b3ee"
SRC_URI += "git://github.com/lithammer/dedent;name=dedent;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/lithammer/dedent"

# [github.com/mdlayher/netlink v1.7.2] git ls-remote https://github.com/mdlayher/netlink 657f7da1d9bd78d246ae610e0b5efc63a6a5f9e4
SRCREV_mdlayher-netlink = "657f7da1d9bd78d246ae610e0b5efc63a6a5f9e4"
SRC_URI += "git://github.com/mdlayher/netlink;name=mdlayher-netlink;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mdlayher/netlink"

# [github.com/mistifyio/go-zfs v2.1.2-0.20190413222219-f784269be439+incompatible] git ls-remote https://github.com/mistifyio/go-zfs f784269be439d704d3dfa1906f45dd848fed2beb
SRCREV_go-zfs = "f784269be439d704d3dfa1906f45dd848fed2beb"
SRC_URI += "git://github.com/mistifyio/go-zfs;name=go-zfs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mistifyio/go-zfs"

# [github.com/moby/sys/symlink v0.2.0] git ls-remote https://github.com/moby/sys 03b9f8d59a07f5206a2264105f4903a222aea964
SRCREV_symlink = "03b9f8d59a07f5206a2264105f4903a222aea964"
SRC_URI += "git://github.com/moby/sys;name=symlink;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/sys/symlink"

# [github.com/syndtr/goleveldb v1.0.0] git ls-remote https://github.com/syndtr/goleveldb 9d007e481048296f09f59bd19bb7ae584563cd95
SRCREV_goleveldb = "9d007e481048296f09f59bd19bb7ae584563cd95"
SRC_URI += "git://github.com/syndtr/goleveldb;name=goleveldb;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/syndtr/goleveldb"

# [github.com/vbatts/tar-split v0.11.5] git ls-remote https://github.com/vbatts/tar-split 5ef0dd8243164ebacd755916a89d8085a5b6bb7f
SRCREV_tar-split = "5ef0dd8243164ebacd755916a89d8085a5b6bb7f"
SRC_URI += "git://github.com/vbatts/tar-split;name=tar-split;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/vbatts/tar-split"

# [google.golang.org/appengine v1.6.8] git ls-remote https://github.com/golang/appengine aa58fcd18e4ab7ac816760ee266fa30a0907ab9e
SRCREV_appengine = "aa58fcd18e4ab7ac816760ee266fa30a0907ab9e"
SRC_URI += "git://github.com/golang/appengine;name=appengine;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/google.golang.org/appengine"

# [sigs.k8s.io/kustomize/kyaml v0.14.1] git ls-remote https://github.com/kubernetes-sigs/kustomize 4ffc8618547a62189d278bd800b3a1fbe5627790
SRCREV_kyaml = "4ffc8618547a62189d278bd800b3a1fbe5627790"
SRC_URI += "git://github.com/kubernetes-sigs/kustomize;name=kyaml;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/kustomize/kyaml"

# [github.com/Microsoft/hcsshim v0.11.0] git ls-remote https://github.com/microsoft/hcsshim 750e11bf07440fd1581413bdc1fc7731fa2d6d64
SRCREV_hcsshim = "750e11bf07440fd1581413bdc1fc7731fa2d6d64"
SRC_URI += "git://github.com/microsoft/hcsshim;name=hcsshim;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Microsoft/hcsshim"

# [github.com/k3s-io/containerd v1.7.17-k3s2.27] git ls-remote https://github.com/k3s-io/containerd 46d753a5c899477bb8836933fc4daac5583875aa
SRCREV_containerd = "46d753a5c899477bb8836933fc4daac5583875aa"
SRC_URI += "git://github.com/k3s-io/containerd;name=containerd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/containerd"

# [github.com/gorilla/websocket v1.5.1] git ls-remote https://github.com/gorilla/websocket ac0789be11725ab2285233e9a3800c2312cff4fc
SRCREV_websocket = "ac0789be11725ab2285233e9a3800c2312cff4fc"
SRC_URI += "git://github.com/gorilla/websocket;name=websocket;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gorilla/websocket"

# [github.com/minio/minio-go/v7 v7.0.70] git ls-remote https://github.com/minio/minio-go c2fe17945c8d0b203fa01e4d04a8adf93ccf2d9f
SRCREV_v7 = "c2fe17945c8d0b203fa01e4d04a8adf93ccf2d9f"
SRC_URI += "git://github.com/minio/minio-go;name=v7;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/minio/minio-go/v7"

# [github.com/yl2chen/cidranger v1.0.2] git ls-remote https://github.com/yl2chen/cidranger 7ff5a0e84593dad6fbd50551343618d7956b3c71
SRCREV_cidranger = "7ff5a0e84593dad6fbd50551343618d7956b3c71"
SRC_URI += "git://github.com/yl2chen/cidranger;name=cidranger;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/yl2chen/cidranger"

# [github.com/k3s-io/kubernetes v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_kubernetes = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=kubernetes;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes"

# [github.com/Azure/go-ansiterm v0.0.0-20210617225240-d185dfc1b5a1] git ls-remote https://github.com/Azure/go-ansiterm d185dfc1b5a126116ea5a19e148e29d16b4574c9
SRCREV_go-ansiterm = "d185dfc1b5a126116ea5a19e148e29d16b4574c9"
SRC_URI += "git://github.com/Azure/go-ansiterm;name=go-ansiterm;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-ansiterm"

# [github.com/Azure/go-autorest v14.2.0+incompatible] git ls-remote https://github.com/Azure/go-autorest e7b391b759b050d6719cc6fd8bb87b6dc038bca6
SRCREV_go-autorest = "e7b391b759b050d6719cc6fd8bb87b6dc038bca6"
SRC_URI += "git://github.com/Azure/go-autorest;name=go-autorest;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-autorest"

# [github.com/avast/retry-go/v4 v4.6.0] git ls-remote https://github.com/avast/retry-go 839c8ceb66c3308e79d46f2552fec3980aaec6f2
SRCREV_v4 = "839c8ceb66c3308e79d46f2552fec3980aaec6f2"
SRC_URI += "git://github.com/avast/retry-go;name=v4;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/avast/retry-go/v4"

# [github.com/benbjohnson/clock v1.3.5] git ls-remote https://github.com/benbjohnson/clock 96c602caabb567343046c08a8fca8560b4f00bb4
SRCREV_clock = "96c602caabb567343046c08a8fca8560b4f00bb4"
SRC_URI += "git://github.com/benbjohnson/clock;name=clock;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/benbjohnson/clock"

# [github.com/cespare/xxhash/v2 v2.2.0] git ls-remote https://github.com/cespare/xxhash a76eb16a93c1e30527c073ca831d9048b4b935f6
SRCREV_xxhash-v2 = "a76eb16a93c1e30527c073ca831d9048b4b935f6"
SRC_URI += "git://github.com/cespare/xxhash;name=xxhash-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cespare/xxhash/v2"

# [github.com/containerd/go-cni v1.1.9] git ls-remote https://github.com/containerd/go-cni 6603d5bd8941d7f2026bb5627f6aa4ff434f859a
SRCREV_go-cni = "6603d5bd8941d7f2026bb5627f6aa4ff434f859a"
SRC_URI += "git://github.com/containerd/go-cni;name=go-cni;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/go-cni"

# [github.com/docker/go-metrics v0.0.1] git ls-remote https://github.com/docker/go-metrics b619b3592b65de4f087d9f16863a7e6ff905973c
SRCREV_go-metrics = "b619b3592b65de4f087d9f16863a7e6ff905973c"
SRC_URI += "git://github.com/docker/go-metrics;name=go-metrics;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/go-metrics"

# [github.com/felixge/httpsnoop v1.0.4] git ls-remote https://github.com/felixge/httpsnoop c5817c27ec125409c069052fdd171023c353501c
SRCREV_httpsnoop = "c5817c27ec125409c069052fdd171023c353501c"
SRC_URI += "git://github.com/felixge/httpsnoop;name=httpsnoop;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/felixge/httpsnoop"

# [github.com/francoispqt/gojay v1.2.13] git ls-remote https://github.com/francoispqt/gojay 1398296d938f9fae26750ddc2fe356b6d897f799
SRCREV_gojay = "1398296d938f9fae26750ddc2fe356b6d897f799"
SRC_URI += "git://github.com/francoispqt/gojay;name=gojay;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/francoispqt/gojay"

# [github.com/fsnotify/fsnotify v1.7.0] git ls-remote https://github.com/fsnotify/fsnotify cfc9c4f277ea6ec18de92444b31983b183deb4fb
SRCREV_fsnotify = "cfc9c4f277ea6ec18de92444b31983b183deb4fb"
SRC_URI += "git://github.com/fsnotify/fsnotify;name=fsnotify;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/fsnotify/fsnotify"

# [github.com/golang-jwt/jwt/v4 v4.4.2] git ls-remote https://github.com/golang-jwt/jwt 9294af54b5fcb8c9c92e3d10ed83d2a7c87fe632
SRCREV_jwt-v4 = "9294af54b5fcb8c9c92e3d10ed83d2a7c87fe632"
SRC_URI += "git://github.com/golang-jwt/jwt;name=jwt-v4;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golang-jwt/jwt/v4"

# [github.com/golang/groupcache v0.0.0-20210331224755-41bb18bfe9da] git ls-remote https://github.com/golang/groupcache 41bb18bfe9da5321badc438f91158cd790a33aa3
SRCREV_groupcache = "41bb18bfe9da5321badc438f91158cd790a33aa3"
SRC_URI += "git://github.com/golang/groupcache;name=groupcache;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golang/groupcache"

# [github.com/hanwen/go-fuse/v2 v2.4.0] git ls-remote https://github.com/hanwen/go-fuse 7b4f97c3577b3b799babe8a6cf3eebe41dde7193
SRCREV_go-fuse-v2 = "7b4f97c3577b3b799babe8a6cf3eebe41dde7193"
SRC_URI += "git://github.com/hanwen/go-fuse;name=go-fuse-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hanwen/go-fuse/v2"

# [github.com/hashicorp/errwrap v1.1.0] git ls-remote https://github.com/hashicorp/errwrap 7b00e5db719c64d14dd0caaacbd13e76254d02c0
SRCREV_errwrap = "7b00e5db719c64d14dd0caaacbd13e76254d02c0"
SRC_URI += "git://github.com/hashicorp/errwrap;name=errwrap;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/errwrap"

# [github.com/ipfs/go-datastore v0.6.0] git ls-remote https://github.com/ipfs/go-datastore 1de47089f5c72b61d91b5cd9043e49fe95771ac0
SRCREV_go-datastore = "1de47089f5c72b61d91b5cd9043e49fe95771ac0"
SRC_URI += "git://github.com/ipfs/go-datastore;name=go-datastore;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ipfs/go-datastore"

# [github.com/karrick/godirwalk v1.17.0] git ls-remote https://github.com/karrick/godirwalk 9a7752c108e7ea76255201b9f47bd4d4d2df868e
SRCREV_godirwalk = "9a7752c108e7ea76255201b9f47bd4d4d2df868e"
SRC_URI += "git://github.com/karrick/godirwalk;name=godirwalk;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/karrick/godirwalk"

# [github.com/liggitt/tabwriter v0.0.0-20181228230101-89fcab3d43de] git ls-remote https://github.com/liggitt/tabwriter 89fcab3d43de07060e4fd4c1547430ed57e87f24
SRCREV_tabwriter = "89fcab3d43de07060e4fd4c1547430ed57e87f24"
SRC_URI += "git://github.com/liggitt/tabwriter;name=tabwriter;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/liggitt/tabwriter"

# [github.com/minio/highwayhash v1.0.2] git ls-remote https://github.com/minio/highwayhash 08ce0b4fa7932a018438133f1b632e1c674d4107
SRCREV_highwayhash = "08ce0b4fa7932a018438133f1b632e1c674d4107"
SRC_URI += "git://github.com/minio/highwayhash;name=highwayhash;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/minio/highwayhash"

# [github.com/minio/sha256-simd v1.0.1] git ls-remote https://github.com/minio/sha256-simd 6096f891a77bfe490cbea7a424c821b5fdb92849
SRCREV_sha256-simd = "6096f891a77bfe490cbea7a424c821b5fdb92849"
SRC_URI += "git://github.com/minio/sha256-simd;name=sha256-simd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/minio/sha256-simd"

# [github.com/mrunalp/fileutils v0.5.1] git ls-remote https://github.com/mrunalp/fileutils 7363e975f9cfb558be601bece0df81714c3c9084
SRCREV_fileutils = "7363e975f9cfb558be601bece0df81714c3c9084"
SRC_URI += "git://github.com/mrunalp/fileutils;name=fileutils;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mrunalp/fileutils"

# [github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822] git ls-remote https://github.com/munnerz/goautoneg a7dc8b61c822528f973a5e4e7b272055c6fdb43e
SRCREV_goautoneg = "a7dc8b61c822528f973a5e4e7b272055c6fdb43e"
SRC_URI += "git://github.com/munnerz/goautoneg;name=goautoneg;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/munnerz/goautoneg"

# [github.com/pelletier/go-toml v1.9.5] git ls-remote https://github.com/pelletier/go-toml fed1464066413075eac02cd4dc368b5221845541
SRCREV_go-toml = "fed1464066413075eac02cd4dc368b5221845541"
SRC_URI += "git://github.com/pelletier/go-toml;name=go-toml;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pelletier/go-toml"

# [github.com/prometheus/common v0.45.0] git ls-remote https://github.com/prometheus/common c59927ec74c04c0c17891bf27784fe7c484ae97f
SRCREV_common = "c59927ec74c04c0c17891bf27784fe7c484ae97f"
SRC_URI += "git://github.com/prometheus/common;name=common;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/prometheus/common"

# [github.com/prometheus/procfs v0.12.0] git ls-remote https://github.com/prometheus/procfs ff0ad85f7e8bcd5c677d99143f14a2a3aab533aa
SRCREV_procfs = "ff0ad85f7e8bcd5c677d99143f14a2a3aab533aa"
SRC_URI += "git://github.com/prometheus/procfs;name=procfs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/prometheus/procfs"

# [github.com/raulk/go-watchdog v1.3.0] git ls-remote https://github.com/raulk/go-watchdog 9c5e371109037bec1852ea63c9512a94307bfea0
SRCREV_go-watchdog = "9c5e371109037bec1852ea63c9512a94307bfea0"
SRC_URI += "git://github.com/raulk/go-watchdog;name=go-watchdog;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/raulk/go-watchdog"

# [github.com/spaolacci/murmur3 v1.1.0] git ls-remote https://github.com/spaolacci/murmur3 f09979ecbc725b9e6d41a297405f65e7e8804acc
SRCREV_murmur3 = "f09979ecbc725b9e6d41a297405f65e7e8804acc"
SRC_URI += "git://github.com/spaolacci/murmur3;name=murmur3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/spaolacci/murmur3"

# [github.com/vishvananda/netns v0.0.4] git ls-remote https://github.com/vishvananda/netns 7a452d2d15292b2bfb2a2d88e6bdeac156a761b9
SRCREV_netns = "7a452d2d15292b2bfb2a2d88e6bdeac156a761b9"
SRC_URI += "git://github.com/vishvananda/netns;name=netns;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/vishvananda/netns"

# [go.opentelemetry.io/otel/sdk v1.13.0] git ls-remote https://github.com/open-telemetry/opentelemetry-go f2fd476f433128c2494476950ce11600a51bbe35
SRCREV_sdk = "f2fd476f433128c2494476950ce11600a51bbe35"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-go;name=sdk;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/otel/sdk"

# [github.com/k3s-io/cri-dockerd v0.3.12-k3s1.27] git ls-remote https://github.com/k3s-io/cri-dockerd 4995f339edcffdf890406b3f1477d34e38477f18
SRCREV_cri-dockerd = "4995f339edcffdf890406b3f1477d34e38477f18"
SRC_URI += "git://github.com/k3s-io/cri-dockerd;name=cri-dockerd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/cri-dockerd"

# [github.com/coreos/go-iptables v0.7.0] git ls-remote https://github.com/coreos/go-iptables b9dff5a19d9c3925da3f9b3c0a705de6c1fdc56c
SRCREV_go-iptables = "b9dff5a19d9c3925da3f9b3c0a705de6c1fdc56c"
SRC_URI += "git://github.com/coreos/go-iptables;name=go-iptables;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/go-iptables"

# [github.com/flannel-io/flannel v0.25.2] git ls-remote https://github.com/flannel-io/flannel bf598473dc712cd7cc8ad2c621969a8c4a134b17
SRCREV_flannel = "bf598473dc712cd7cc8ad2c621969a8c4a134b17"
SRC_URI += "git://github.com/flannel-io/flannel;name=flannel;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/flannel-io/flannel"

# [github.com/ipfs/go-ds-leveldb v0.5.0] git ls-remote https://github.com/ipfs/go-ds-leveldb 6f6dc580f7325ad411fc5967ccee67e40545e208
SRCREV_go-ds-leveldb = "6f6dc580f7325ad411fc5967ccee67e40545e208"
SRC_URI += "git://github.com/ipfs/go-ds-leveldb;name=go-ds-leveldb;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ipfs/go-ds-leveldb"

# [github.com/klauspost/compress v1.17.7] git ls-remote https://github.com/klauspost/compress 1e2b27500c4eae851ba753ad116dc5a6524d2366
SRCREV_compress = "1e2b27500c4eae851ba753ad116dc5a6524d2366"
SRC_URI += "git://github.com/klauspost/compress;name=compress;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/klauspost/compress"

# [github.com/k3s-io/etcd/api/v3 v3.5.13-k3s1] git ls-remote https://github.com/k3s-io/etcd a455a25f07e9e4661927dc4cd47b6e2b93ee3c08
SRCREV_api-v3 = "a455a25f07e9e4661927dc4cd47b6e2b93ee3c08"
SRC_URI += "git://github.com/k3s-io/etcd;name=api-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/api/v3"

# [github.com/JeffAshton/win_pdh v0.0.0-20161109143554-76bb4ee9f0ab] git ls-remote https://github.com/JeffAshton/win_pdh 76bb4ee9f0ab50f77826f2a2ee7fb9d3880d6ec2
SRCREV_win_pdh = "76bb4ee9f0ab50f77826f2a2ee7fb9d3880d6ec2"
SRC_URI += "git://github.com/JeffAshton/win_pdh;name=win_pdh;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/JeffAshton/win_pdh"

# [github.com/Microsoft/go-winio v0.6.2] git ls-remote https://github.com/microsoft/go-winio 3c9576c9346a1892dee136329e7e15309e82fb4f
SRCREV_go-winio = "3c9576c9346a1892dee136329e7e15309e82fb4f"
SRC_URI += "git://github.com/microsoft/go-winio;name=go-winio;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Microsoft/go-winio"

# [github.com/containerd/cgroups v1.1.0] git ls-remote https://github.com/containerd/cgroups fe7323f622bc222e72473679f12a9089aeeda177
SRCREV_cgroups = "fe7323f622bc222e72473679f12a9089aeeda177"
SRC_URI += "git://github.com/containerd/cgroups;name=cgroups;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/cgroups"

# [github.com/containerd/console v1.0.3] git ls-remote https://github.com/containerd/console b5cb846c9186d67bcae3ce3c324e47cd317d9527
SRCREV_console = "b5cb846c9186d67bcae3ce3c324e47cd317d9527"
SRC_URI += "git://github.com/containerd/console;name=console;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/console"

# [github.com/containerd/go-runc v1.0.0] git ls-remote https://github.com/containerd/go-runc 16b287bc67d069a60fa48db15f330b790b74365b
SRCREV_go-runc = "16b287bc67d069a60fa48db15f330b790b74365b"
SRC_URI += "git://github.com/containerd/go-runc;name=go-runc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/go-runc"

# [github.com/containerd/typeurl v1.0.2] git ls-remote https://github.com/containerd/typeurl 5e43fb8b75ed2f2305fc04e6918c8d10636771bc
SRCREV_typeurl = "5e43fb8b75ed2f2305fc04e6918c8d10636771bc"
SRC_URI += "git://github.com/containerd/typeurl;name=typeurl;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/typeurl"

# [github.com/dustin/go-humanize v1.0.1] git ls-remote https://github.com/dustin/go-humanize 9ec74ab2f7a7161664182fd4e5e292fccffbc75f
SRCREV_go-humanize = "9ec74ab2f7a7161664182fd4e5e292fccffbc75f"
SRC_URI += "git://github.com/dustin/go-humanize;name=go-humanize;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/dustin/go-humanize"

# [github.com/evanphx/json-patch v5.6.0+incompatible] git ls-remote https://github.com/evanphx/json-patch 5561fe05a1ec79c9bca966376211b2ab81959671
SRCREV_json-patch = "5561fe05a1ec79c9bca966376211b2ab81959671"
SRC_URI += "git://github.com/evanphx/json-patch;name=json-patch;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/evanphx/json-patch"

# [github.com/fvbommel/sortorder v1.0.1] git ls-remote https://github.com/fvbommel/sortorder a1ddee917217bbd0691affdca9c88d24d3f5c27d
SRCREV_sortorder = "a1ddee917217bbd0691affdca9c88d24d3f5c27d"
SRC_URI += "git://github.com/fvbommel/sortorder;name=sortorder;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/fvbommel/sortorder"

# [github.com/go-jose/go-jose/v3 v3.0.3] git ls-remote https://github.com/go-jose/go-jose add6a284ea0f844fd6628cba637be5451fe4b28a
SRCREV_go-jose-v3 = "add6a284ea0f844fd6628cba637be5451fe4b28a"
SRC_URI += "git://github.com/go-jose/go-jose;name=go-jose-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-jose/go-jose/v3"

# [github.com/go-task/slim-sprig v0.0.0-20230315185526-52ccab3ef572] git ls-remote https://github.com/go-task/slim-sprig 52ccab3ef572c7e1a2c258be183f9a9296d60152
SRCREV_slim-sprig = "52ccab3ef572c7e1a2c258be183f9a9296d60152"
SRC_URI += "git://github.com/go-task/slim-sprig;name=slim-sprig;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-task/slim-sprig"

# [github.com/ipld/go-ipld-prime v0.20.0] git ls-remote https://github.com/ipld/go-ipld-prime 200b4a6b6fb6720911cb385aff05da55c39d56de
SRCREV_go-ipld-prime = "200b4a6b6fb6720911cb385aff05da55c39d56de"
SRC_URI += "git://github.com/ipld/go-ipld-prime;name=go-ipld-prime;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ipld/go-ipld-prime"

# [github.com/jackpal/go-nat-pmp v1.0.2] git ls-remote https://github.com/jackpal/go-nat-pmp 059203efa1edd7130293a583541b8308e7c640c4
SRCREV_go-nat-pmp = "059203efa1edd7130293a583541b8308e7c640c4"
SRC_URI += "git://github.com/jackpal/go-nat-pmp;name=go-nat-pmp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jackpal/go-nat-pmp"

# [github.com/klauspost/cpuid/v2 v2.2.7] git ls-remote https://github.com/klauspost/cpuid 486f6ae65fec6bbb15e6f6bff15036f7bc50d4c4
SRCREV_cpuid-v2 = "486f6ae65fec6bbb15e6f6bff15036f7bc50d4c4"
SRC_URI += "git://github.com/klauspost/cpuid;name=cpuid-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/klauspost/cpuid/v2"

# [github.com/kylelemons/godebug v1.1.0] git ls-remote https://github.com/kylelemons/godebug 9ff306d4fbead574800b66369df5b6144732d58e
SRCREV_godebug = "9ff306d4fbead574800b66369df5b6144732d58e"
SRC_URI += "git://github.com/kylelemons/godebug;name=godebug;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kylelemons/godebug"

# [github.com/libp2p/go-netroute v0.2.1] git ls-remote https://github.com/libp2p/go-netroute 462cbfaf52f4c2a2321e6382455a8f56396f3664
SRCREV_go-netroute = "462cbfaf52f4c2a2321e6382455a8f56396f3664"
SRC_URI += "git://github.com/libp2p/go-netroute;name=go-netroute;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-netroute"

# [github.com/libp2p/go-yamux/v4 v4.0.1] git ls-remote https://github.com/libp2p/go-yamux e584a210c72651b67829477b4b4285cae25b1a1b
SRCREV_go-yamux-v4 = "e584a210c72651b67829477b4b4285cae25b1a1b"
SRC_URI += "git://github.com/libp2p/go-yamux;name=go-yamux-v4;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-yamux/v4"

# [github.com/marten-seemann/tcp v0.0.0-20210406111302-dfbc87cc63fd] git ls-remote https://github.com/marten-seemann/tcp dfbc87cc63fd003b9a070c76d605769fa3e2e3b2
SRCREV_tcp = "dfbc87cc63fd003b9a070c76d605769fa3e2e3b2"
SRC_URI += "git://github.com/marten-seemann/tcp;name=tcp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/marten-seemann/tcp"

# [github.com/mdlayher/genetlink v1.3.2] git ls-remote https://github.com/mdlayher/genetlink 7531bffe0f5e10d1ce558d35e6feb5d1d1600851
SRCREV_genetlink = "7531bffe0f5e10d1ce558d35e6feb5d1d1600851"
SRC_URI += "git://github.com/mdlayher/genetlink;name=genetlink;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mdlayher/genetlink"

# [github.com/moby/sys/mountinfo v0.6.2] git ls-remote https://github.com/moby/sys 1bf36f7188c31f2797c556c4c4d7d9af7a6a965b
SRCREV_mountinfo = "1bf36f7188c31f2797c556c4c4d7d9af7a6a965b"
SRC_URI += "git://github.com/moby/sys;name=mountinfo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/sys/mountinfo"

# [github.com/modern-go/reflect2 v1.0.2] git ls-remote https://github.com/modern-go/reflect2 2b33151c9bbc5231aea69b8861c540102b087070
SRCREV_reflect2 = "2b33151c9bbc5231aea69b8861c540102b087070"
SRC_URI += "git://github.com/modern-go/reflect2;name=reflect2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/modern-go/reflect2"

# [github.com/peterbourgon/diskv v2.0.1+incompatible] git ls-remote https://github.com/peterbourgon/diskv 5f041e8faa004a95c88a202771f4cc3e991971e6
SRCREV_diskv = "5f041e8faa004a95c88a202771f4cc3e991971e6"
SRC_URI += "git://github.com/peterbourgon/diskv;name=diskv;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/peterbourgon/diskv"

# [github.com/pmezard/go-difflib v1.0.1-0.20181226105442-5d4384ee4fb2] git ls-remote https://github.com/pmezard/go-difflib 5d4384ee4fb2527b0a1256a821ebfc92f91efefc
SRCREV_go-difflib = "5d4384ee4fb2527b0a1256a821ebfc92f91efefc"
SRC_URI += "git://github.com/pmezard/go-difflib;name=go-difflib;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pmezard/go-difflib"

# [github.com/shengdoushi/base58 v1.0.0] git ls-remote https://github.com/shengdoushi/base58 c5f44ca1af76fb63925d5fba8fa7b85870199839
SRCREV_shengdoushi-base58 = "c5f44ca1af76fb63925d5fba8fa7b85870199839"
SRC_URI += "git://github.com/shengdoushi/base58;name=shengdoushi-base58;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/shengdoushi/base58"

# [github.com/stoewer/go-strcase v1.2.0] git ls-remote https://github.com/stoewer/go-strcase 7962b205553802087345c0b4c74d57b65236f676
SRCREV_go-strcase = "7962b205553802087345c0b4c74d57b65236f676"
SRC_URI += "git://github.com/stoewer/go-strcase;name=go-strcase;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/stoewer/go-strcase"

# [github.com/k3s-io/etcd/pkg/v3 v3.5.13-k3s1] git ls-remote https://github.com/k3s-io/etcd a455a25f07e9e4661927dc4cd47b6e2b93ee3c08
SRCREV_pkg-v3 = "a455a25f07e9e4661927dc4cd47b6e2b93ee3c08"
SRC_URI += "git://github.com/k3s-io/etcd;name=pkg-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/pkg/v3"

# [github.com/erikdubbelboer/gspt v0.0.0-20190125194910-e68493906b83] git ls-remote https://github.com/erikdubbelboer/gspt e68493906b8382891943ddc9960cb9c6ecd1a1f0
SRCREV_gspt = "e68493906b8382891943ddc9960cb9c6ecd1a1f0"
SRC_URI += "git://github.com/erikdubbelboer/gspt;name=gspt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/erikdubbelboer/gspt"

# [github.com/go-sql-driver/mysql v1.7.1] git ls-remote https://github.com/go-sql-driver/mysql f20b2863636093e5fbf1481b59bdaff3b0fbb779
SRCREV_mysql = "f20b2863636093e5fbf1481b59bdaff3b0fbb779"
SRC_URI += "git://github.com/go-sql-driver/mysql;name=mysql;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-sql-driver/mysql"

# [github.com/rancher/permissions v0.0.0-20240523180510-4001d3d637f7] git ls-remote https://github.com/rancher/permissions 4001d3d637f7e7f9aa17c84d89b2462539f1b331
SRCREV_permissions = "4001d3d637f7e7f9aa17c84d89b2462539f1b331"
SRC_URI += "git://github.com/rancher/permissions;name=permissions;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/permissions"

# [github.com/vishvananda/netlink v1.2.1-beta.2] git ls-remote https://github.com/vishvananda/netlink 5e915e0149386ce3d02379ff93f4c0a5601779d5
SRCREV_netlink = "5e915e0149386ce3d02379ff93f4c0a5601779d5"
SRC_URI += "git://github.com/vishvananda/netlink;name=netlink;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/vishvananda/netlink"

# [github.com/MakeNowJust/heredoc v1.0.0] git ls-remote https://github.com/makenowjust/heredoc bbd9af33722b79a933ef99c7c94833065e2d6c20
SRCREV_heredoc = "bbd9af33722b79a933ef99c7c94833065e2d6c20"
SRC_URI += "git://github.com/makenowjust/heredoc;name=heredoc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/MakeNowJust/heredoc"

# [github.com/NYTimes/gziphandler v1.1.1] git ls-remote https://github.com/nytimes/gziphandler dd0439581c7657cb652dfe5c71d7d48baf39541d
SRCREV_gziphandler = "dd0439581c7657cb652dfe5c71d7d48baf39541d"
SRC_URI += "git://github.com/nytimes/gziphandler;name=gziphandler;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/NYTimes/gziphandler"

# [github.com/canonical/go-dqlite v1.5.1] git ls-remote https://github.com/canonical/go-dqlite 830c1a017995b73322e86c2a6f2ca799c1caca07
SRCREV_go-dqlite = "830c1a017995b73322e86c2a6f2ca799c1caca07"
SRC_URI += "git://github.com/canonical/go-dqlite;name=go-dqlite;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/canonical/go-dqlite"

# [github.com/cenkalti/backoff/v4 v4.2.1] git ls-remote https://github.com/cenkalti/backoff a04a6fe64ffb0e3fd0816460529d300be5f252df
SRCREV_backoff-v4 = "a04a6fe64ffb0e3fd0816460529d300be5f252df"
SRC_URI += "git://github.com/cenkalti/backoff;name=backoff-v4;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cenkalti/backoff/v4"

# [github.com/chai2010/gettext-go v1.0.2] git ls-remote https://github.com/chai2010/gettext-go 274d1753d015d0362761b6a1cc2a572e6a035913
SRCREV_gettext-go = "274d1753d015d0362761b6a1cc2a572e6a035913"
SRC_URI += "git://github.com/chai2010/gettext-go;name=gettext-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/chai2010/gettext-go"

# [github.com/containerd/btrfs/v2 v2.0.0] git ls-remote https://github.com/containerd/btrfs f611cf12b33f43269574b2ad82bcb55e4d6f9982
SRCREV_btrfs-v2 = "f611cf12b33f43269574b2ad82bcb55e4d6f9982"
SRC_URI += "git://github.com/containerd/btrfs;name=btrfs-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/btrfs/v2"

# [github.com/containerd/imgcrypt v1.1.8] git ls-remote https://github.com/containerd/imgcrypt 061ead6edbef40cca81adb6230afba10413f7db6
SRCREV_imgcrypt = "061ead6edbef40cca81adb6230afba10413f7db6"
SRC_URI += "git://github.com/containerd/imgcrypt;name=imgcrypt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/imgcrypt"

# [github.com/containers/ocicrypt v1.1.10] git ls-remote https://github.com/containers/ocicrypt ccaf1f86ed8ce962ed5909808113bc84b5684018
SRCREV_ocicrypt = "ccaf1f86ed8ce962ed5909808113bc84b5684018"
SRC_URI += "git://github.com/containers/ocicrypt;name=ocicrypt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containers/ocicrypt"

# [github.com/docker/distribution v2.8.3+incompatible] git ls-remote https://github.com/distribution/distribution 4772604ae973031ab32dd9805a4bccf61d94909f
SRCREV_distribution = "4772604ae973031ab32dd9805a4bccf61d94909f"
SRC_URI += "git://github.com/distribution/distribution;name=distribution;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/distribution"

# [github.com/emicklei/go-restful v2.16.0+incompatible] git ls-remote https://github.com/emicklei/go-restful ac666c045e035603f2704c98c59e979fccbfa94f
SRCREV_go-restful = "ac666c045e035603f2704c98c59e979fccbfa94f"
SRC_URI += "git://github.com/emicklei/go-restful;name=go-restful;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/emicklei/go-restful"

# [github.com/gregjones/httpcache v0.0.0-20180305231024-9cad4c3443a7] git ls-remote https://github.com/gregjones/httpcache 9cad4c3443a7200dd6400aef47183728de563a38
SRCREV_httpcache = "9cad4c3443a7200dd6400aef47183728de563a38"
SRC_URI += "git://github.com/gregjones/httpcache;name=httpcache;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gregjones/httpcache"

# [github.com/jackc/pgservicefile v0.0.0-20221227161230-091c0ba34f0a] git ls-remote https://github.com/jackc/pgservicefile 091c0ba34f0a65a78ab8d0e313fde0695c0f7186
SRCREV_pgservicefile = "091c0ba34f0a65a78ab8d0e313fde0695c0f7186"
SRC_URI += "git://github.com/jackc/pgservicefile;name=pgservicefile;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jackc/pgservicefile"

# [github.com/jonboulle/clockwork v0.4.0] git ls-remote https://github.com/jonboulle/clockwork 606c48b92358fcca153952b56fb0d14d6845f84a
SRCREV_clockwork = "606c48b92358fcca153952b56fb0d14d6845f84a"
SRC_URI += "git://github.com/jonboulle/clockwork;name=clockwork;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jonboulle/clockwork"

# [github.com/libp2p/go-cidranger v1.1.0] git ls-remote https://github.com/libp2p/go-cidranger 1dec7f87b45b32e24d3f59548ad61647de34586d
SRCREV_go-cidranger = "1dec7f87b45b32e24d3f59548ad61647de34586d"
SRC_URI += "git://github.com/libp2p/go-cidranger;name=go-cidranger;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-cidranger"

# [github.com/libp2p/go-reuseport v0.4.0] git ls-remote https://github.com/libp2p/go-reuseport ac34b4fb35437abcc176b5bb97cc431d62d983e0
SRCREV_go-reuseport = "ac34b4fb35437abcc176b5bb97cc431d62d983e0"
SRC_URI += "git://github.com/libp2p/go-reuseport;name=go-reuseport;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-reuseport"

# [github.com/mistifyio/go-zfs/v3 v3.0.1] git ls-remote https://github.com/mistifyio/go-zfs f6d5c373cf63ae2477370aa9bda9fa49804c2d72
SRCREV_go-zfs-v3 = "f6d5c373cf63ae2477370aa9bda9fa49804c2d72"
SRC_URI += "git://github.com/mistifyio/go-zfs;name=go-zfs-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mistifyio/go-zfs/v3"

# [github.com/moby/sys/sequential v0.5.0] git ls-remote https://github.com/moby/sys b22ba8a69b306f0b4adbbe2a529457e6283ed9f7
SRCREV_sequential = "b22ba8a69b306f0b4adbbe2a529457e6283ed9f7"
SRC_URI += "git://github.com/moby/sys;name=sequential;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/sys/sequential"

# [github.com/syndtr/gocapability v0.0.0-20200815063812-42c35b437635] git ls-remote https://github.com/syndtr/gocapability 42c35b4376354fd554efc7ad35e0b7f94e3a0ffb
SRCREV_gocapability = "42c35b4376354fd554efc7ad35e0b7f94e3a0ffb"
SRC_URI += "git://github.com/syndtr/gocapability;name=gocapability;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/syndtr/gocapability"

# [github.com/k3s-io/etcd/raft/v3 v3.5.13-k3s1] git ls-remote https://github.com/k3s-io/etcd a455a25f07e9e4661927dc4cd47b6e2b93ee3c08
SRCREV_raft-v3 = "a455a25f07e9e4661927dc4cd47b6e2b93ee3c08"
SRC_URI += "git://github.com/k3s-io/etcd;name=raft-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/raft/v3"

# [go.opentelemetry.io/otel/trace v1.13.0] git ls-remote https://github.com/open-telemetry/opentelemetry-go f2fd476f433128c2494476950ce11600a51bbe35
SRCREV_trace = "f2fd476f433128c2494476950ce11600a51bbe35"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-go;name=trace;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/otel/trace"

# [go.opentelemetry.io/proto/otlp v0.19.0] git ls-remote https://github.com/open-telemetry/opentelemetry-proto-go c98f6b5f7362c9b4a717c7a4dab1ba90796a8f21
SRCREV_otlp = "c98f6b5f7362c9b4a717c7a4dab1ba90796a8f21"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-proto-go;name=otlp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/proto/otlp"

# [github.com/natefinch/lumberjack v2.0.0+incompatible] git ls-remote https://github.com/natefinch/lumberjack 7d6a1875575e09256dc552b4c0e450dcd02bd10e
SRCREV_lumberjack = "7d6a1875575e09256dc552b4c0e450dcd02bd10e"
SRC_URI += "git://github.com/natefinch/lumberjack;name=lumberjack;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/natefinch/lumberjack"

# [github.com/rancher/remotedialer v0.3.0] git ls-remote https://github.com/rancher/remotedialer 24498689a9ccec9adbdbadbe3f5d18df75ba133b
SRCREV_remotedialer = "24498689a9ccec9adbdbadbe3f5d18df75ba133b"
SRC_URI += "git://github.com/rancher/remotedialer;name=remotedialer;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/remotedialer"

# [github.com/davidlazar/go-crypto v0.0.0-20200604182044-b73af7476f6c] git ls-remote https://github.com/davidlazar/go-crypto b73af7476f6c55b31aa2797d1f98afc94699548d
SRCREV_go-crypto = "b73af7476f6c55b31aa2797d1f98afc94699548d"
SRC_URI += "git://github.com/davidlazar/go-crypto;name=go-crypto;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/davidlazar/go-crypto"

# [github.com/euank/go-kmsg-parser v2.0.0+incompatible] git ls-remote https://github.com/euank/go-kmsg-parser 5ba4d492e455a77d25dcf0d2c4acc9f2afebef4e
SRCREV_go-kmsg-parser = "5ba4d492e455a77d25dcf0d2c4acc9f2afebef4e"
SRC_URI += "git://github.com/euank/go-kmsg-parser;name=go-kmsg-parser;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/euank/go-kmsg-parser"

# [github.com/exponent-io/jsonpath v0.0.0-20151013193312-d6023ce2651d] git ls-remote https://github.com/exponent-io/jsonpath d6023ce2651d8eafb5c75bb0c7167536102ec9f5
SRCREV_jsonpath = "d6023ce2651d8eafb5c75bb0c7167536102ec9f5"
SRC_URI += "git://github.com/exponent-io/jsonpath;name=jsonpath;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/exponent-io/jsonpath"

# [github.com/googleapis/gax-go/v2 v2.1.1] git ls-remote https://github.com/googleapis/gax-go 0968b165da19974432147e6058bc859f6c488642
SRCREV_gax-go-v2 = "0968b165da19974432147e6058bc859f6c488642"
SRC_URI += "git://github.com/googleapis/gax-go;name=gax-go-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/googleapis/gax-go/v2"

# [github.com/hashicorp/go-version v1.6.0] git ls-remote https://github.com/hashicorp/go-version 78d058c5618891f74d604bd15356fca690b64d8a
SRCREV_go-version = "78d058c5618891f74d604bd15356fca690b64d8a"
SRC_URI += "git://github.com/hashicorp/go-version;name=go-version;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-version"

# [github.com/hashicorp/golang-lru v0.5.4] git ls-remote https://github.com/hashicorp/golang-lru 14eae340515388ca95aa8e7b86f0de668e981f54
SRCREV_golang-lru = "14eae340515388ca95aa8e7b86f0de668e981f54"
SRC_URI += "git://github.com/hashicorp/golang-lru;name=golang-lru;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/golang-lru"

# [github.com/mitchellh/go-homedir v1.1.0] git ls-remote https://github.com/mitchellh/go-homedir af06845cf3004701891bf4fdb884bfe4920b3727
SRCREV_go-homedir = "af06845cf3004701891bf4fdb884bfe4920b3727"
SRC_URI += "git://github.com/mitchellh/go-homedir;name=go-homedir;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mitchellh/go-homedir"

# [github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd] git ls-remote https://github.com/modern-go/concurrent bacd9c7ef1dd9b15be4a9909b8ac7a4e313eec94
SRCREV_concurrent = "bacd9c7ef1dd9b15be4a9909b8ac7a4e313eec94"
SRC_URI += "git://github.com/modern-go/concurrent;name=concurrent;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/modern-go/concurrent"

# [github.com/pelletier/go-toml/v2 v2.2.2] git ls-remote https://github.com/pelletier/go-toml a3d5a0bb530b5206c728eed9cb57323061922bcb
SRCREV_go-toml-v2 = "a3d5a0bb530b5206c728eed9cb57323061922bcb"
SRC_URI += "git://github.com/pelletier/go-toml;name=go-toml-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pelletier/go-toml/v2"

# [github.com/pquerna/cachecontrol v0.1.0] git ls-remote https://github.com/pquerna/cachecontrol fb00f8a766ae43bf209f50299ce7d69669416dfb
SRCREV_cachecontrol = "fb00f8a766ae43bf209f50299ce7d69669416dfb"
SRC_URI += "git://github.com/pquerna/cachecontrol;name=cachecontrol;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pquerna/cachecontrol"

# [github.com/tchap/go-patricia/v2 v2.3.1] git ls-remote https://github.com/tchap/go-patricia 5fc88dd7937ad82ca516f7f1f6b2c06dd0180309
SRCREV_go-patricia-v2 = "5fc88dd7937ad82ca516f7f1f6b2c06dd0180309"
SRC_URI += "git://github.com/tchap/go-patricia;name=go-patricia-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/tchap/go-patricia/v2"

# [go.opentelemetry.io/otel/metric v0.32.1] git ls-remote https://github.com/open-telemetry/opentelemetry-go d7bfe6675fe79b0c01cae3d4c5f06330b2fece73
SRCREV_metric = "d7bfe6675fe79b0c01cae3d4c5f06330b2fece73"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-go;name=metric;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/otel/metric"

# [github.com/k3s-io/kube-router/v2 v2.1.2] git ls-remote https://github.com/k3s-io/kube-router 09d6f45f56e0945fd8e443150dd93461c9c76266
SRCREV_v2 = "09d6f45f56e0945fd8e443150dd93461c9c76266"
SRC_URI += "git://github.com/k3s-io/kube-router;name=v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kube-router/v2"

# [github.com/containerd/cgroups/v3 v3.0.2] git ls-remote https://github.com/containerd/cgroups 8fa64246e17ceea54277b3ad7139d9ec17545bfa
SRCREV_v3 = "8fa64246e17ceea54277b3ad7139d9ec17545bfa"
SRC_URI += "git://github.com/containerd/cgroups;name=v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/cgroups/v3"

# [github.com/coreos/go-systemd/v22 v22.5.0] git ls-remote https://github.com/coreos/go-systemd d5623bf85e8e73ae6352f78ee6b55a287619dd4e
SRCREV_v22 = "d5623bf85e8e73ae6352f78ee6b55a287619dd4e"
SRC_URI += "git://github.com/coreos/go-systemd;name=v22;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/go-systemd/v22"

# [github.com/go-bindata/go-bindata v3.1.2+incompatible] git ls-remote https://github.com/go-bindata/go-bindata ff7109080027ec152dabb369e157c4f359b76f31
SRCREV_go-bindata = "ff7109080027ec152dabb369e157c4f359b76f31"
SRC_URI += "git://github.com/go-bindata/go-bindata;name=go-bindata;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-bindata/go-bindata"

# [github.com/k3s-io/etcd/client/v3 v3.5.13-k3s1] git ls-remote https://github.com/k3s-io/etcd a455a25f07e9e4661927dc4cd47b6e2b93ee3c08
SRCREV_client-v3 = "a455a25f07e9e4661927dc4cd47b6e2b93ee3c08"
SRC_URI += "git://github.com/k3s-io/etcd;name=client-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/client/v3"

# [github.com/k3s-io/etcd/server/v3 v3.5.13-k3s1] git ls-remote https://github.com/k3s-io/etcd a455a25f07e9e4661927dc4cd47b6e2b93ee3c08
SRCREV_server-v3 = "a455a25f07e9e4661927dc4cd47b6e2b93ee3c08"
SRC_URI += "git://github.com/k3s-io/etcd;name=server-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/server/v3"

# [github.com/containerd/continuity v0.4.3] git ls-remote https://github.com/containerd/continuity 1743d9104d944131cdedaba33a59d2f9bd80a6f2
SRCREV_continuity = "1743d9104d944131cdedaba33a59d2f9bd80a6f2"
SRC_URI += "git://github.com/containerd/continuity;name=continuity;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/continuity"

# [github.com/containerd/typeurl/v2 v2.1.1] git ls-remote https://github.com/containerd/typeurl 7ef6316b771f959cbb208b229e3423a466947df3
SRCREV_typeurl-v2 = "7ef6316b771f959cbb208b229e3423a466947df3"
SRC_URI += "git://github.com/containerd/typeurl;name=typeurl-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/typeurl/v2"

# [github.com/cpuguy83/go-md2man/v2 v2.0.3] git ls-remote https://github.com/cpuguy83/go-md2man f67b5f6400a3ea2156517041a329ae5f5935395c
SRCREV_go-md2man-v2 = "f67b5f6400a3ea2156517041a329ae5f5935395c"
SRC_URI += "git://github.com/cpuguy83/go-md2man;name=go-md2man-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cpuguy83/go-md2man/v2"

# [github.com/docker/go-connections v0.5.0] git ls-remote https://github.com/docker/go-connections fa09c952e3eadbffaf8afc5b8a1667158ba38ace
SRCREV_go-connections = "fa09c952e3eadbffaf8afc5b8a1667158ba38ace"
SRC_URI += "git://github.com/docker/go-connections;name=go-connections;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/go-connections"

# [github.com/google/gnostic-models v0.6.9-0.20230804172637-c7be7c783f49] git ls-remote https://github.com/google/gnostic-models c7be7c783f49e86348a1081eb387e01a347a4f23
SRCREV_gnostic-models = "c7be7c783f49e86348a1081eb387e01a347a4f23"
SRC_URI += "git://github.com/google/gnostic-models;name=gnostic-models;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/gnostic-models"

# [github.com/libp2p/go-buffer-pool v0.1.0] git ls-remote https://github.com/libp2p/go-buffer-pool c5070857211a0615ebd7b56588154941af580a4d
SRCREV_go-buffer-pool = "c5070857211a0615ebd7b56588154941af580a4d"
SRC_URI += "git://github.com/libp2p/go-buffer-pool;name=go-buffer-pool;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-buffer-pool"

# [github.com/mitchellh/go-wordwrap v1.0.1] git ls-remote https://github.com/mitchellh/go-wordwrap ecf0936a077a4bd73a1cc2ac5c370f2b55618d62
SRCREV_go-wordwrap = "ecf0936a077a4bd73a1cc2ac5c370f2b55618d62"
SRC_URI += "git://github.com/mitchellh/go-wordwrap;name=go-wordwrap;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mitchellh/go-wordwrap"

# [github.com/k3s-io/etcd/client/v2 v2.305.13-k3s1] git ls-remote https://github.com/k3s-io/etcd a455a25f07e9e4661927dc4cd47b6e2b93ee3c08
SRCREV_client-v2 = "a455a25f07e9e4661927dc4cd47b6e2b93ee3c08"
SRC_URI += "git://github.com/k3s-io/etcd;name=client-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/client/v2"

# [gopkg.in/natefinch/lumberjack.v2 v2.0.0] git ls-remote https://github.com/natefinch/lumberjack 7d6a1875575e09256dc552b4c0e450dcd02bd10e
SRCREV_lumberjack.v2 = "7d6a1875575e09256dc552b4c0e450dcd02bd10e"
SRC_URI += "git://github.com/natefinch/lumberjack;name=lumberjack.v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/natefinch/lumberjack.v2"

# [github.com/k3s-io/helm-controller v0.15.10] git ls-remote https://github.com/k3s-io/helm-controller 7c32f6dca1a006975f4880978e77682e2a8a7315
SRCREV_helm-controller = "7c32f6dca1a006975f4880978e77682e2a8a7315"
SRC_URI += "git://github.com/k3s-io/helm-controller;name=helm-controller;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/helm-controller"

# [github.com/mwitkow/go-http-dialer v0.0.0-20161116154839-378f744fb2b8] git ls-remote https://github.com/mwitkow/go-http-dialer 378f744fb2b81a6b96e3f40cde4f3bcab5a9cff0
SRCREV_go-http-dialer = "378f744fb2b81a6b96e3f40cde4f3bcab5a9cff0"
SRC_URI += "git://github.com/mwitkow/go-http-dialer;name=go-http-dialer;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mwitkow/go-http-dialer"

# [github.com/opencontainers/selinux v1.10.1] git ls-remote https://github.com/opencontainers/selinux 84e248a28e776216cd33a51fdea90a20fe308136
SRCREV_selinux = "84e248a28e776216cd33a51fdea90a20fe308136"
SRC_URI += "git://github.com/opencontainers/selinux;name=selinux;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opencontainers/selinux"

# [github.com/k3s-io/etcd/etcdutl/v3 v3.5.13-k3s1] git ls-remote https://github.com/k3s-io/etcd a455a25f07e9e4661927dc4cd47b6e2b93ee3c08
SRCREV_etcdutl-v3 = "a455a25f07e9e4661927dc4cd47b6e2b93ee3c08"
SRC_URI += "git://github.com/k3s-io/etcd;name=etcdutl-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/etcdutl/v3"

# [github.com/Azure/azure-sdk-for-go v56.3.0+incompatible] git ls-remote https://github.com/Azure/azure-sdk-for-go 93a97cc2993453b1328d7f9210cfe5f0ace602a1
SRCREV_azure-sdk-for-go = "93a97cc2993453b1328d7f9210cfe5f0ace602a1"
SRC_URI += "git://github.com/Azure/azure-sdk-for-go;name=azure-sdk-for-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/azure-sdk-for-go"

# [github.com/asaskevich/govalidator v0.0.0-20190424111038-f61b66f89f4a] git ls-remote https://github.com/asaskevich/govalidator f61b66f89f4a311bef65f13e575bcf1a2ffadda6
SRCREV_govalidator = "f61b66f89f4a311bef65f13e575bcf1a2ffadda6"
SRC_URI += "git://github.com/asaskevich/govalidator;name=govalidator;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/asaskevich/govalidator"

# [github.com/distribution/reference v0.5.0] git ls-remote https://github.com/distribution/reference 49c28499d219290c3226822e9cfcd4ede6d75379
SRCREV_reference = "49c28499d219290c3226822e9cfcd4ede6d75379"
SRC_URI += "git://github.com/distribution/reference;name=reference;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/distribution/reference"

# [github.com/emicklei/go-restful/v3 v3.9.0] git ls-remote https://github.com/emicklei/go-restful ce871fa2f7069b65c784c9c708da1f00b1f2bd66
SRCREV_go-restful-v3 = "ce871fa2f7069b65c784c9c708da1f00b1f2bd66"
SRC_URI += "git://github.com/emicklei/go-restful;name=go-restful-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/emicklei/go-restful/v3"

# [github.com/go-openapi/jsonpointer v0.20.2] git ls-remote https://github.com/go-openapi/jsonpointer 344388f5b9184a55dea9d36cf96742b69dddeac4
SRCREV_jsonpointer = "344388f5b9184a55dea9d36cf96742b69dddeac4"
SRC_URI += "git://github.com/go-openapi/jsonpointer;name=jsonpointer;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/jsonpointer"

# [github.com/hashicorp/go-cleanhttp v0.5.2] git ls-remote https://github.com/hashicorp/go-cleanhttp 6d9e2ac5d828e5f8594b97f88c4bde14a67bb6d2
SRCREV_go-cleanhttp = "6d9e2ac5d828e5f8594b97f88c4bde14a67bb6d2"
SRC_URI += "git://github.com/hashicorp/go-cleanhttp;name=go-cleanhttp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-cleanhttp"

# [github.com/libp2p/go-flow-metrics v0.1.0] git ls-remote https://github.com/libp2p/go-flow-metrics 3f13d05958e2d1be0245aed1bdb38f9ff1b4efdc
SRCREV_go-flow-metrics = "3f13d05958e2d1be0245aed1bdb38f9ff1b4efdc"
SRC_URI += "git://github.com/libp2p/go-flow-metrics;name=go-flow-metrics;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-flow-metrics"

# [github.com/mitchellh/mapstructure v1.5.0] git ls-remote https://github.com/mitchellh/mapstructure ab69d8d93410fce4361f4912bb1ff88110a81311
SRCREV_mapstructure = "ab69d8d93410fce4361f4912bb1ff88110a81311"
SRC_URI += "git://github.com/mitchellh/mapstructure;name=mapstructure;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mitchellh/mapstructure"

# [github.com/multiformats/go-base32 v0.1.0] git ls-remote https://github.com/multiformats/go-base32 a16b66327f327428b32b919939b8c93482507e1f
SRCREV_go-base32 = "a16b66327f327428b32b919939b8c93482507e1f"
SRC_URI += "git://github.com/multiformats/go-base32;name=go-base32;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/multiformats/go-base32"

# [github.com/multiformats/go-base36 v0.2.0] git ls-remote https://github.com/multiformats/go-base36 da52c98bb97cfaa321be04030bc97dcee7de63ff
SRCREV_go-base36 = "da52c98bb97cfaa321be04030bc97dcee7de63ff"
SRC_URI += "git://github.com/multiformats/go-base36;name=go-base36;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/multiformats/go-base36"

# [github.com/multiformats/go-varint v0.0.7] git ls-remote https://github.com/multiformats/go-varint 8c8129accb08fc978bb276c81d568c41eafdd48f
SRCREV_go-varint = "8c8129accb08fc978bb276c81d568c41eafdd48f"
SRC_URI += "git://github.com/multiformats/go-varint;name=go-varint;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/multiformats/go-varint"

# [github.com/nats-io/nats-server/v2 v2.10.12] git ls-remote https://github.com/nats-io/nats-server 121169ea86756a853a418446b9c7591df761b49d
SRCREV_nats-server-v2 = "121169ea86756a853a418446b9c7591df761b49d"
SRC_URI += "git://github.com/nats-io/nats-server;name=nats-server-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/nats-io/nats-server/v2"

# [golang.zx2c4.com/wireguard/wgctrl v0.0.0-20230429144221-925a1e7659e6] git ls-remote https://github.com/WireGuard/wgctrl-go 925a1e7659e675c94c1a659d39daa9141e450c7d
SRCREV_wgctrl = "925a1e7659e675c94c1a659d39daa9141e450c7d"
SRC_URI += "git://github.com/WireGuard/wgctrl-go;name=wgctrl;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.zx2c4.com/wireguard/wgctrl"

# [github.com/rancher/dynamiclistener v0.3.6] git ls-remote https://github.com/rancher/dynamiclistener 0a2d8dff62fde6dfaf009141c12b30c316d8cff3
SRCREV_dynamiclistener = "0a2d8dff62fde6dfaf009141c12b30c316d8cff3"
SRC_URI += "git://github.com/rancher/dynamiclistener;name=dynamiclistener;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/dynamiclistener"

# [github.com/containernetworking/cni v1.1.2] git ls-remote https://github.com/containernetworking/cni 3363d143688bb83ca18489ac8b9dc204c1d49c4a
SRCREV_cni = "3363d143688bb83ca18489ac8b9dc204c1d49c4a"
SRC_URI += "git://github.com/containernetworking/cni;name=cni;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containernetworking/cni"

# [github.com/hashicorp/go-multierror v1.1.1] git ls-remote https://github.com/hashicorp/go-multierror 9974e9ec57696378079ecc3accd3d6f29401b3a0
SRCREV_go-multierror = "9974e9ec57696378079ecc3accd3d6f29401b3a0"
SRC_URI += "git://github.com/hashicorp/go-multierror;name=go-multierror;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-multierror"

# [github.com/hashicorp/golang-lru/v2 v2.0.5] git ls-remote https://github.com/hashicorp/golang-lru 99d7b177d1c3f01ae145e824fe627961e76edb8b
SRCREV_golang-lru-v2 = "99d7b177d1c3f01ae145e824fe627961e76edb8b"
SRC_URI += "git://github.com/hashicorp/golang-lru;name=golang-lru-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/golang-lru/v2"

# [github.com/libp2p/go-libp2p-record v0.2.0] git ls-remote https://github.com/libp2p/go-libp2p-record 90bb9b0e21ffe5e9a5f1af1c1e8cc6d9a0fce24c
SRCREV_go-libp2p-record = "90bb9b0e21ffe5e9a5f1af1c1e8cc6d9a0fce24c"
SRC_URI += "git://github.com/libp2p/go-libp2p-record;name=go-libp2p-record;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-libp2p-record"

# [github.com/prometheus/client_model v0.6.0] git ls-remote https://github.com/prometheus/client_model d56cd794bca9543da8cc93e95432cd64d5f99635
SRCREV_client_model = "d56cd794bca9543da8cc93e95432cd64d5f99635"
SRC_URI += "git://github.com/prometheus/client_model;name=client_model;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/prometheus/client_model"

# [github.com/quic-go/webtransport-go v0.6.0] git ls-remote https://github.com/quic-go/webtransport-go 3697690b8131a891190093bd6d10ca6e3906a620
SRCREV_webtransport-go = "3697690b8131a891190093bd6d10ca6e3906a620"
SRC_URI += "git://github.com/quic-go/webtransport-go;name=webtransport-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/quic-go/webtransport-go"

# [github.com/russross/blackfriday/v2 v2.1.0] git ls-remote https://github.com/russross/blackfriday 4c9bf9512682b995722660a4196c0013228e2049
SRCREV_blackfriday-v2 = "4c9bf9512682b995722660a4196c0013228e2049"
SRC_URI += "git://github.com/russross/blackfriday;name=blackfriday-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/russross/blackfriday/v2"

# [sigs.k8s.io/kustomize/kustomize/v5 v5.0.1] git ls-remote https://github.com/kubernetes-sigs/kustomize 39527da73ca50df19b7678b8f7e87fa94b326296
SRCREV_kustomize-v5 = "39527da73ca50df19b7678b8f7e87fa94b326296"
SRC_URI += "git://github.com/kubernetes-sigs/kustomize;name=kustomize-v5;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/kustomize/kustomize/v5"

# [github.com/prometheus/client_golang v1.18.0] git ls-remote https://github.com/prometheus/client_golang 53be91d12107cb69053a8792d0a3a2a6124d59cf
SRCREV_client_golang = "53be91d12107cb69053a8792d0a3a2a6124d59cf"
SRC_URI += "git://github.com/prometheus/client_golang;name=client_golang;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/prometheus/client_golang"

# [github.com/Azure/go-autorest/logger v0.2.1] git ls-remote https://github.com/Azure/go-autorest 820a319d2214dc91d083022ae5ec50070175314c
SRCREV_logger = "820a319d2214dc91d083022ae5ec50070175314c"
SRC_URI += "git://github.com/Azure/go-autorest;name=logger;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-autorest/logger"

# [github.com/daviddengcn/go-colortext v1.0.0] git ls-remote https://github.com/daviddengcn/go-colortext dc4cd66b56a892657c0bea8bf4389d35210ce0ee
SRCREV_go-colortext = "dc4cd66b56a892657c0bea8bf4389d35210ce0ee"
SRC_URI += "git://github.com/daviddengcn/go-colortext;name=go-colortext;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/daviddengcn/go-colortext"

# [github.com/go-openapi/jsonreference v0.20.4] git ls-remote https://github.com/go-openapi/jsonreference 23cc9ccbfd88d2589a00b1567f7fe61119c41375
SRCREV_jsonreference = "23cc9ccbfd88d2589a00b1567f7fe61119c41375"
SRC_URI += "git://github.com/go-openapi/jsonreference;name=jsonreference;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/jsonreference"

# [github.com/libp2p/go-libp2p-kad-dht v0.25.2] git ls-remote https://github.com/libp2p/go-libp2p-kad-dht bdca14419ec5f7ad0790f17856964bb99bee7436
SRCREV_go-libp2p-kad-dht = "bdca14419ec5f7ad0790f17856964bb99bee7436"
SRC_URI += "git://github.com/libp2p/go-libp2p-kad-dht;name=go-libp2p-kad-dht;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-libp2p-kad-dht"

# [github.com/libp2p/go-libp2p-kbucket v0.6.3] git ls-remote https://github.com/libp2p/go-libp2p-kbucket 437b9fccd6a22835a67b8fe2a5eae0b92f307224
SRCREV_go-libp2p-kbucket = "437b9fccd6a22835a67b8fe2a5eae0b92f307224"
SRC_URI += "git://github.com/libp2p/go-libp2p-kbucket;name=go-libp2p-kbucket;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-libp2p-kbucket"

# [github.com/opencontainers/go-digest v1.0.0] git ls-remote https://github.com/opencontainers/go-digest ea51bea511f75cfa3ef6098cc253c5c3609b037a
SRCREV_go-digest = "ea51bea511f75cfa3ef6098cc253c5c3609b037a"
SRC_URI += "git://github.com/opencontainers/go-digest;name=go-digest;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opencontainers/go-digest"

# [github.com/tmc/grpc-websocket-proxy v0.0.0-20220101234140-673ab2c3ae75] git ls-remote https://github.com/tmc/grpc-websocket-proxy 673ab2c3ae75cc01952b84b88590e30e75dcf395
SRCREV_grpc-websocket-proxy = "673ab2c3ae75cc01952b84b88590e30e75dcf395"
SRC_URI += "git://github.com/tmc/grpc-websocket-proxy;name=grpc-websocket-proxy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/tmc/grpc-websocket-proxy"

# [github.com/k3s-io/etcd/client/pkg/v3 v3.5.13-k3s1] git ls-remote https://github.com/k3s-io/etcd a455a25f07e9e4661927dc4cd47b6e2b93ee3c08
SRCREV_pkg-v3 = "a455a25f07e9e4661927dc4cd47b6e2b93ee3c08"
SRC_URI += "git://github.com/k3s-io/etcd;name=pkg-v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/client/pkg/v3"

# [cloud.google.com/go/compute/metadata v0.2.3] git ls-remote https://github.com/googleapis/google-cloud-go cf8081fada0955a1682ce3fc400b44bc141309c7
SRCREV_metadata = "cf8081fada0955a1682ce3fc400b44bc141309c7"
SRC_URI += "git://github.com/googleapis/google-cloud-go;name=metadata;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/cloud.google.com/go/compute/metadata"

# [github.com/AdaLogics/go-fuzz-headers v0.0.0-20230811130428-ced1acdcaa24] git ls-remote https://github.com/AdaLogics/go-fuzz-headers ced1acdcaa24dc39c01b039fc37576c395f506cf
SRCREV_go-fuzz-headers = "ced1acdcaa24dc39c01b039fc37576c395f506cf"
SRC_URI += "git://github.com/AdaLogics/go-fuzz-headers;name=go-fuzz-headers;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/AdaLogics/go-fuzz-headers"

# [github.com/Azure/go-autorest/tracing v0.6.0] git ls-remote https://github.com/Azure/go-autorest b3a0b30a7423314874b3f585289e0e260cf5fc8d
SRCREV_tracing = "b3a0b30a7423314874b3f585289e0e260cf5fc8d"
SRC_URI += "git://github.com/Azure/go-autorest;name=tracing;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-autorest/tracing"

# [github.com/inconshreveable/mousetrap v1.1.0] git ls-remote https://github.com/inconshreveable/mousetrap 4e8053ee7ef85a6bd26368364a6d27f1641c1d21
SRCREV_mousetrap = "4e8053ee7ef85a6bd26368364a6d27f1641c1d21"
SRC_URI += "git://github.com/inconshreveable/mousetrap;name=mousetrap;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/inconshreveable/mousetrap"

# [github.com/libp2p/go-libp2p-asn-util v0.4.1] git ls-remote https://github.com/libp2p/go-libp2p-asn-util 3ec6bf02c86c57c28d29b2963a9d7b9d6d74bfb2
SRCREV_go-libp2p-asn-util = "3ec6bf02c86c57c28d29b2963a9d7b9d6d74bfb2"
SRC_URI += "git://github.com/libp2p/go-libp2p-asn-util;name=go-libp2p-asn-util;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-libp2p-asn-util"

# [github.com/multiformats/go-multiaddr v0.12.3] git ls-remote https://github.com/multiformats/go-multiaddr cece70d472926ca09b0eca7aca63224653d1de69
SRCREV_go-multiaddr = "cece70d472926ca09b0eca7aca63224653d1de69"
SRC_URI += "git://github.com/multiformats/go-multiaddr;name=go-multiaddr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/multiformats/go-multiaddr"

# [github.com/multiformats/go-multibase v0.2.0] git ls-remote https://github.com/multiformats/go-multibase 58a41f7df1d82d16599e259325b3337d69f70e3b
SRCREV_go-multibase = "58a41f7df1d82d16599e259325b3337d69f70e3b"
SRC_URI += "git://github.com/multiformats/go-multibase;name=go-multibase;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/multiformats/go-multibase"

# [github.com/multiformats/go-multihash v0.2.3] git ls-remote https://github.com/multiformats/go-multihash ff9da31500dddfc675e996601a05cdfc3ce7c764
SRCREV_go-multihash = "ff9da31500dddfc675e996601a05cdfc3ce7c764"
SRC_URI += "git://github.com/multiformats/go-multihash;name=go-multihash;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/multiformats/go-multihash"

# [github.com/opencontainers/image-spec v1.1.0] git ls-remote https://github.com/opencontainers/image-spec e7f7c0ca69b21688c3cea7c87a04e4503e6099e2
SRCREV_image-spec = "e7f7c0ca69b21688c3cea7c87a04e4503e6099e2"
SRC_URI += "git://github.com/opencontainers/image-spec;name=image-spec;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opencontainers/image-spec"

# [github.com/seccomp/libseccomp-golang v0.9.2-0.20220502022130-f33da4d89646] git ls-remote https://github.com/seccomp/libseccomp-golang f33da4d89646b6c01cb104d81094208b83a9b8e4
SRCREV_libseccomp-golang = "f33da4d89646b6c01cb104d81094208b83a9b8e4"
SRC_URI += "git://github.com/seccomp/libseccomp-golang;name=libseccomp-golang;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/seccomp/libseccomp-golang"

# [github.com/stefanberger/go-pkcs11uri v0.0.0-20230803200340-78284954bff6] git ls-remote https://github.com/stefanberger/go-pkcs11uri 78284954bff6dcce7888166bb79bbba93bea0879
SRCREV_go-pkcs11uri = "78284954bff6dcce7888166bb79bbba93bea0879"
SRC_URI += "git://github.com/stefanberger/go-pkcs11uri;name=go-pkcs11uri;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/stefanberger/go-pkcs11uri"

# [github.com/whyrusleeping/go-keyspace v0.0.0-20160322163242-5b898ac5add1] git ls-remote https://github.com/whyrusleeping/go-keyspace 5b898ac5add1da7178a4a98e69cb7b9205c085ee
SRCREV_go-keyspace = "5b898ac5add1da7178a4a98e69cb7b9205c085ee"
SRC_URI += "git://github.com/whyrusleeping/go-keyspace;name=go-keyspace;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/whyrusleeping/go-keyspace"

# [sigs.k8s.io/structured-merge-diff/v4 v4.4.1] git ls-remote https://github.com/kubernetes-sigs/structured-merge-diff cf09e71f4508bfc416135048e392a8a4990bf4e3
SRCREV_structured-merge-diff-v4 = "cf09e71f4508bfc416135048e392a8a4990bf4e3"
SRC_URI += "git://github.com/kubernetes-sigs/structured-merge-diff;name=structured-merge-diff-v4;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/structured-merge-diff/v4"

# [github.com/Azure/go-autorest/autorest v0.11.27] git ls-remote https://github.com/Azure/go-autorest 7525a9bd0079c3842a7e11a93bd76166e915b0f1
SRCREV_autorest = "7525a9bd0079c3842a7e11a93bd76166e915b0f1"
SRC_URI += "git://github.com/Azure/go-autorest;name=autorest;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-autorest/autorest"

# [github.com/cyphar/filepath-securejoin v0.2.4] git ls-remote https://github.com/cyphar/filepath-securejoin 2710d06c5b4ba3168beffa0689798d2db12e8ac4
SRCREV_filepath-securejoin = "2710d06c5b4ba3168beffa0689798d2db12e8ac4"
SRC_URI += "git://github.com/cyphar/filepath-securejoin;name=filepath-securejoin;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cyphar/filepath-securejoin"

# [github.com/hashicorp/go-retryablehttp v0.7.4] git ls-remote https://github.com/hashicorp/go-retryablehttp 571a88bc9c3b7c64575f0e9b0f646af1510f2c76
SRCREV_go-retryablehttp = "571a88bc9c3b7c64575f0e9b0f646af1510f2c76"
SRC_URI += "git://github.com/hashicorp/go-retryablehttp;name=go-retryablehttp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-retryablehttp"

# [github.com/jbenet/go-temp-err-catcher v0.1.0] git ls-remote https://github.com/jbenet/go-temp-err-catcher fa11adda5e7cccb838a208007c9ea79dda63c0c0
SRCREV_go-temp-err-catcher = "fa11adda5e7cccb838a208007c9ea79dda63c0c0"
SRC_URI += "git://github.com/jbenet/go-temp-err-catcher;name=go-temp-err-catcher;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jbenet/go-temp-err-catcher"

# [github.com/libopenstorage/openstorage v1.0.0] git ls-remote https://github.com/libopenstorage/openstorage 093a0c3888753c2056e7373183693d670c6bba01
SRCREV_openstorage = "093a0c3888753c2056e7373183693d670c6bba01"
SRC_URI += "git://github.com/libopenstorage/openstorage;name=openstorage;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libopenstorage/openstorage"

# [github.com/multiformats/go-multicodec v0.9.0] git ls-remote https://github.com/multiformats/go-multicodec b8b4bf5270f9f220f00bcdeddf1641b13e67cc0b
SRCREV_go-multicodec = "b8b4bf5270f9f220f00bcdeddf1641b13e67cc0b"
SRC_URI += "git://github.com/multiformats/go-multicodec;name=go-multicodec;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/multiformats/go-multicodec"

# [github.com/opentracing/opentracing-go v1.2.0] git ls-remote https://github.com/opentracing/opentracing-go d34af3eaa63c4d08ab54863a4bdd0daa45212e12
SRCREV_opentracing-go = "d34af3eaa63c4d08ab54863a4bdd0daa45212e12"
SRC_URI += "git://github.com/opentracing/opentracing-go;name=opentracing-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opentracing/opentracing-go"

# [github.com/AdamKorcz/go-118-fuzz-build v0.0.0-20230306123547-8075edf89bb0] git ls-remote https://github.com/AdamKorcz/go-118-fuzz-build 8075edf89bb034603c758f28fe93143047ac5677
SRCREV_go-118-fuzz-build = "8075edf89bb034603c758f28fe93143047ac5677"
SRC_URI += "git://github.com/AdamKorcz/go-118-fuzz-build;name=go-118-fuzz-build;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/AdamKorcz/go-118-fuzz-build"

# [github.com/bronze1man/goStrongswanVici v0.0.0-20221114103242-3f6dc524986c] git ls-remote https://github.com/bronze1man/goStrongswanVici 3f6dc524986c8a20ee1e139f9e1bef1595877b5d
SRCREV_goStrongswanVici = "3f6dc524986c8a20ee1e139f9e1bef1595877b5d"
SRC_URI += "git://github.com/bronze1man/goStrongswanVici;name=goStrongswanVici;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/bronze1man/goStrongswanVici"

# [github.com/containernetworking/plugins v1.4.1] git ls-remote https://github.com/containernetworking/plugins 8fc26ce7a09a7eb77a04edafcf61e3224c3a2b4f
SRCREV_plugins = "8fc26ce7a09a7eb77a04edafcf61e3224c3a2b4f"
SRC_URI += "git://github.com/containernetworking/plugins;name=plugins;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containernetworking/plugins"

# [github.com/google/go-containerregistry v0.14.0] git ls-remote https://github.com/google/go-containerregistry 4b081f801f399fa293f23e42ba4c4ac6a6003f2c
SRCREV_go-containerregistry = "4b081f801f399fa293f23e42ba4c4ac6a6003f2c"
SRC_URI += "git://github.com/google/go-containerregistry;name=go-containerregistry;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/go-containerregistry"

# [github.com/grpc-ecosystem/grpc-gateway v1.16.0] git ls-remote https://github.com/grpc-ecosystem/grpc-gateway 094a6fe78b3ca888297d090185cdf30f0e42e157
SRCREV_grpc-gateway = "094a6fe78b3ca888297d090185cdf30f0e42e157"
SRC_URI += "git://github.com/grpc-ecosystem/grpc-gateway;name=grpc-gateway;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/grpc-ecosystem/grpc-gateway"

# [github.com/hashicorp/golang-lru/arc/v2 v2.0.5] git ls-remote https://github.com/hashicorp/golang-lru 3afaa48530f711754c178ceb61ff060d86c17b95
SRCREV_arc-v2 = "3afaa48530f711754c178ceb61ff060d86c17b95"
SRC_URI += "git://github.com/hashicorp/golang-lru;name=arc-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/golang-lru/arc/v2"

# [github.com/monochromegane/go-gitignore v0.0.0-20200626010858-205db1a8cc00] git ls-remote https://github.com/monochromegane/go-gitignore 205db1a8cc001de79230472da52edde4974df734
SRCREV_go-gitignore = "205db1a8cc001de79230472da52edde4974df734"
SRC_URI += "git://github.com/monochromegane/go-gitignore;name=go-gitignore;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/monochromegane/go-gitignore"

# [github.com/multiformats/go-multistream v0.5.0] git ls-remote https://github.com/multiformats/go-multistream 8fabf3a244c16743222174f11b43cf4a47c6d5e8
SRCREV_go-multistream = "8fabf3a244c16743222174f11b43cf4a47c6d5e8"
SRC_URI += "git://github.com/multiformats/go-multistream;name=go-multistream;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/multiformats/go-multistream"

# [github.com/opencontainers/runtime-spec v1.0.3-0.20220909204839-494a5a6aca78] git ls-remote https://github.com/opencontainers/runtime-spec 494a5a6aca782455c0fbfc35af8e12f04e98a55e
SRCREV_runtime-spec = "494a5a6aca782455c0fbfc35af8e12f04e98a55e"
SRC_URI += "git://github.com/opencontainers/runtime-spec;name=runtime-spec;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opencontainers/runtime-spec"

# [github.com/opencontainers/runtime-tools v0.9.1-0.20221107090550-2e043c6bd626] git ls-remote https://github.com/opencontainers/runtime-tools 2e043c6bd62639199bdd0d5f0c5082797de4de2a
SRCREV_runtime-tools = "2e043c6bd62639199bdd0d5f0c5082797de4de2a"
SRC_URI += "git://github.com/opencontainers/runtime-tools;name=runtime-tools;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opencontainers/runtime-tools"

# [tags.cncf.io/container-device-interface v0.7.2] git ls-remote https://github.com/cncf-tags/container-device-interface d7f87365dfce93c70f9d13f1873731b2f3e79e95
SRCREV_container-device-interface = "d7f87365dfce93c70f9d13f1873731b2f3e79e95"
SRC_URI += "git://github.com/cncf-tags/container-device-interface;name=container-device-interface;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/tags.cncf.io/container-device-interface"

# [github.com/containerd/stargz-snapshotter v0.15.1] git ls-remote https://github.com/containerd/stargz-snapshotter 64ab83bd65cd4a763e262955984232cc5ddfeb3f
SRCREV_stargz-snapshotter = "64ab83bd65cd4a763e262955984232cc5ddfeb3f"
SRC_URI += "git://github.com/containerd/stargz-snapshotter;name=stargz-snapshotter;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/stargz-snapshotter"

# [github.com/Azure/go-autorest/autorest/to v0.4.0] git ls-remote https://github.com/Azure/go-autorest b3a0b30a7423314874b3f585289e0e260cf5fc8d
SRCREV_to = "b3a0b30a7423314874b3f585289e0e260cf5fc8d"
SRC_URI += "git://github.com/Azure/go-autorest;name=to;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-autorest/autorest/to"

# [github.com/antlr/antlr4/runtime/Go/antlr v1.4.10] git ls-remote https://github.com/antlr/antlr4 cd8f367ca010eb59defadf3df622793bc3a8afe2
SRCREV_antlr = "cd8f367ca010eb59defadf3df622793bc3a8afe2"
SRC_URI += "git://github.com/antlr/antlr4;name=antlr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/antlr/antlr4/runtime/Go/antlr"

# [github.com/checkpoint-restore/go-criu/v5 v5.3.0] git ls-remote https://github.com/checkpoint-restore/go-criu e3059103a5cf6adca2183e08c0315e8d8d5135a5
SRCREV_v5 = "e3059103a5cf6adca2183e08c0315e8d8d5135a5"
SRC_URI += "git://github.com/checkpoint-restore/go-criu;name=v5;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/checkpoint-restore/go-criu/v5"

# [github.com/multiformats/go-multiaddr-dns v0.3.1] git ls-remote https://github.com/multiformats/go-multiaddr-dns 448c10b622b0c09ce6834487156c1fd9a65f1597
SRCREV_go-multiaddr-dns = "448c10b622b0c09ce6834487156c1fd9a65f1597"
SRC_URI += "git://github.com/multiformats/go-multiaddr-dns;name=go-multiaddr-dns;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/multiformats/go-multiaddr-dns"

# [github.com/multiformats/go-multiaddr-fmt v0.1.0] git ls-remote https://github.com/multiformats/go-multiaddr-fmt 113ed87ed03cfff94f29fd95236be3ccd933fd36
SRCREV_go-multiaddr-fmt = "113ed87ed03cfff94f29fd95236be3ccd933fd36"
SRC_URI += "git://github.com/multiformats/go-multiaddr-fmt;name=go-multiaddr-fmt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/multiformats/go-multiaddr-fmt"

# [github.com/decred/dcrd/dcrec/secp256k1/v4 v4.2.0] git ls-remote https://github.com/decred/dcrd bacf8444a8bc79178f9eb2c65477ab6df01a6439
SRCREV_secp256k1-v4 = "bacf8444a8bc79178f9eb2c65477ab6df01a6439"
SRC_URI += "git://github.com/decred/dcrd;name=secp256k1-v4;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/decred/dcrd/dcrec/secp256k1/v4"

# [github.com/grpc-ecosystem/grpc-gateway/v2 v2.16.0] git ls-remote https://github.com/grpc-ecosystem/grpc-gateway 09e3965a330155f7db8482269d7d91b9bceb7641
SRCREV_grpc-gateway-v2 = "09e3965a330155f7db8482269d7d91b9bceb7641"
SRC_URI += "git://github.com/grpc-ecosystem/grpc-gateway;name=grpc-gateway-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/grpc-ecosystem/grpc-gateway/v2"

# [github.com/rootless-containers/rootlesskit v1.0.1] git ls-remote https://github.com/rootless-containers/rootlesskit 5d5f4c0c26e26a6b51d1838c23e793e5836442d0
SRCREV_rootlesskit = "5d5f4c0c26e26a6b51d1838c23e793e5836442d0"
SRC_URI += "git://github.com/rootless-containers/rootlesskit;name=rootlesskit;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rootless-containers/rootlesskit"

# [github.com/Azure/go-autorest/autorest/adal v0.9.20] git ls-remote https://github.com/Azure/go-autorest 7dd32b67be4e6c9386b9ba7b1c44a51263f05270
SRCREV_adal = "7dd32b67be4e6c9386b9ba7b1c44a51263f05270"
SRC_URI += "git://github.com/Azure/go-autorest;name=adal;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-autorest/autorest/adal"

# [github.com/Azure/go-autorest/autorest/date v0.3.0] git ls-remote https://github.com/Azure/go-autorest b3a0b30a7423314874b3f585289e0e260cf5fc8d
SRCREV_date = "b3a0b30a7423314874b3f585289e0e260cf5fc8d"
SRC_URI += "git://github.com/Azure/go-autorest;name=date;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-autorest/autorest/date"

# [github.com/Azure/go-autorest/autorest/mocks v0.4.2] git ls-remote https://github.com/Azure/go-autorest a91292dd2fc10381ac9b90eea72b92e60761eac4
SRCREV_mocks = "a91292dd2fc10381ac9b90eea72b92e60761eac4"
SRC_URI += "git://github.com/Azure/go-autorest;name=mocks;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-autorest/autorest/mocks"

# [github.com/container-storage-interface/spec v1.7.0] git ls-remote https://github.com/container-storage-interface/spec 5d1ebe63079c01d127631ad336087df94b083a54
SRCREV_spec = "5d1ebe63079c01d127631ad336087df94b083a54"
SRC_URI += "git://github.com/container-storage-interface/spec;name=spec;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/container-storage-interface/spec"

# [github.com/docker/docker-credential-helpers v0.7.0] git ls-remote https://github.com/docker/docker-credential-helpers ac5992b5f4756fc0398a7d0c93c609e624368bde
SRCREV_docker-credential-helpers = "ac5992b5f4756fc0398a7d0c93c609e624368bde"
SRC_URI += "git://github.com/docker/docker-credential-helpers;name=docker-credential-helpers;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/docker-credential-helpers"

# [github.com/libp2p/go-libp2p-routing-helpers v0.7.2] git ls-remote https://github.com/libp2p/go-libp2p-routing-helpers 71d7c965185ed346e39cc26140ac49ea13b2222f
SRCREV_go-libp2p-routing-helpers = "71d7c965185ed346e39cc26140ac49ea13b2222f"
SRC_URI += "git://github.com/libp2p/go-libp2p-routing-helpers;name=go-libp2p-routing-helpers;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libp2p/go-libp2p-routing-helpers"

# [github.com/grpc-ecosystem/go-grpc-middleware v1.3.0] git ls-remote https://github.com/grpc-ecosystem/go-grpc-middleware df0f91b29bbbdfc3a686a7a8edbe2b9de2072fdd
SRCREV_go-grpc-middleware = "df0f91b29bbbdfc3a686a7a8edbe2b9de2072fdd"
SRC_URI += "git://github.com/grpc-ecosystem/go-grpc-middleware;name=go-grpc-middleware;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/grpc-ecosystem/go-grpc-middleware"

# [github.com/grpc-ecosystem/go-grpc-prometheus v1.2.0] git ls-remote https://github.com/grpc-ecosystem/go-grpc-prometheus c225b8c3b01faf2899099b768856a9e916e5087b
SRCREV_go-grpc-prometheus = "c225b8c3b01faf2899099b768856a9e916e5087b"
SRC_URI += "git://github.com/grpc-ecosystem/go-grpc-prometheus;name=go-grpc-prometheus;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/grpc-ecosystem/go-grpc-prometheus"

# [github.com/containerd/fuse-overlayfs-snapshotter v1.0.8] git ls-remote https://github.com/containerd/fuse-overlayfs-snapshotter c54d1c1d71bd1cdc25bbae89208bea0267858ae9
SRCREV_fuse-overlayfs-snapshotter = "c54d1c1d71bd1cdc25bbae89208bea0267858ae9"
SRC_URI += "git://github.com/containerd/fuse-overlayfs-snapshotter;name=fuse-overlayfs-snapshotter;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/fuse-overlayfs-snapshotter"

# [github.com/Azure/go-autorest/autorest/validation v0.3.1] git ls-remote https://github.com/Azure/go-autorest 446f41b7d65b2ab6c25b1a7afe42abd3622e9110
SRCREV_validation = "446f41b7d65b2ab6c25b1a7afe42abd3622e9110"
SRC_URI += "git://github.com/Azure/go-autorest;name=validation;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-autorest/autorest/validation"

# [github.com/containerd/stargz-snapshotter/estargz v0.15.1] git ls-remote https://github.com/containerd/stargz-snapshotter 64ab83bd65cd4a763e262955984232cc5ddfeb3f
SRCREV_estargz = "64ab83bd65cd4a763e262955984232cc5ddfeb3f"
SRC_URI += "git://github.com/containerd/stargz-snapshotter;name=estargz;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/stargz-snapshotter/estargz"

# [tags.cncf.io/container-device-interface/specs-go v0.7.0] git ls-remote https://github.com/cncf-tags/container-device-interface 780f60f5e4ac27d7b1c729a986ed7edbb6af7c12
SRCREV_specs-go = "780f60f5e4ac27d7b1c729a986ed7edbb6af7c12"
SRC_URI += "git://github.com/cncf-tags/container-device-interface;name=specs-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/tags.cncf.io/container-device-interface/specs-go"

# [github.com/GoogleCloudPlatform/k8s-cloud-provider v1.18.1-0.20220218231025-f11817397a1b] git ls-remote https://github.com/GoogleCloudPlatform/k8s-cloud-provider f11817397a1bb27e88115807a9c083a36e12eaf8
SRCREV_k8s-cloud-provider = "f11817397a1bb27e88115807a9c083a36e12eaf8"
SRC_URI += "git://github.com/GoogleCloudPlatform/k8s-cloud-provider;name=k8s-cloud-provider;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/GoogleCloudPlatform/k8s-cloud-provider"

# [go.opentelemetry.io/otel/exporters/otlp/otlptrace v1.13.0] git ls-remote https://github.com/open-telemetry/opentelemetry-go f2fd476f433128c2494476950ce11600a51bbe35
SRCREV_otlptrace = "f2fd476f433128c2494476950ce11600a51bbe35"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-go;name=otlptrace;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/otel/exporters/otlp/otlptrace"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/api v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_api = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=api;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/api"

# [github.com/matttproud/golang_protobuf_extensions/v2 v2.0.0] git ls-remote https://github.com/matttproud/golang_protobuf_extensions 5a0f9169fc38cc42a5c617c3dc049548ddc27487
SRCREV_golang_protobuf_extensions-v2 = "5a0f9169fc38cc42a5c617c3dc049548ddc27487"
SRC_URI += "git://github.com/matttproud/golang_protobuf_extensions;name=golang_protobuf_extensions-v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/matttproud/golang_protobuf_extensions/v2"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/kms v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_kms = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=kms;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/kms"

# [go.opentelemetry.io/otel/exporters/otlp/internal/retry v1.13.0] git ls-remote https://github.com/open-telemetry/opentelemetry-go f2fd476f433128c2494476950ce11600a51bbe35
SRCREV_internal-retry = "f2fd476f433128c2494476950ce11600a51bbe35"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-go;name=internal-retry;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/otel/exporters/otlp/internal/retry"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/cri-api v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_cri-api = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=cri-api;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/cri-api"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/kubectl v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_kubectl = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=kubectl;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/kubectl"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/kubelet v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_kubelet = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=kubelet;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/kubelet"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/metrics v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_metrics = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=metrics;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/metrics"

# [sigs.k8s.io/apiserver-network-proxy/konnectivity-client v0.1.2] git ls-remote https://github.com/kubernetes-sigs/apiserver-network-proxy 60b5f0e02800910cbb363668e285ec0e78d7cae1
SRCREV_konnectivity-client = "60b5f0e02800910cbb363668e285ec0e78d7cae1"
SRC_URI += "git://github.com/kubernetes-sigs/apiserver-network-proxy;name=konnectivity-client;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/apiserver-network-proxy/konnectivity-client"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/apiserver v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_apiserver = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=apiserver;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/apiserver"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/client-go v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_client-go = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=client-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/client-go"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/kube-proxy v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_kube-proxy = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=kube-proxy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/kube-proxy"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/cli-runtime v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_cli-runtime = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=cli-runtime;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/cli-runtime"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/mount-utils v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_mount-utils = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=mount-utils;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/mount-utils"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/apimachinery v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_apimachinery = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=apimachinery;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/apimachinery"

# [go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp v0.35.1] git ls-remote https://github.com/open-telemetry/opentelemetry-go-contrib 356ee7f4343df3704346603fbde1b8d3d8fb86e9
SRCREV_otelhttp = "356ee7f4343df3704346603fbde1b8d3d8fb86e9"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-go-contrib;name=otelhttp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/cloud-provider v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_cloud-provider = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=cloud-provider;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/cloud-provider"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/component-base v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_component-base = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=component-base;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/component-base"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/code-generator v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_code-generator = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=code-generator;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/code-generator"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/kube-scheduler v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_kube-scheduler = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=kube-scheduler;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/kube-scheduler"

# [go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc v1.13.0] git ls-remote https://github.com/open-telemetry/opentelemetry-go f2fd476f433128c2494476950ce11600a51bbe35
SRCREV_otlptracegrpc = "f2fd476f433128c2494476950ce11600a51bbe35"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-go;name=otlptracegrpc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/kube-aggregator v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_kube-aggregator = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=kube-aggregator;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/kube-aggregator"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/cluster-bootstrap v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_cluster-bootstrap = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=cluster-bootstrap;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/cluster-bootstrap"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/component-helpers v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_component-helpers = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=component-helpers;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/component-helpers"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/controller-manager v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_controller-manager = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=controller-manager;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/controller-manager"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/csi-translation-lib v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_csi-translation-lib = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=csi-translation-lib;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/csi-translation-lib"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/legacy-cloud-providers v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_legacy-cloud-providers = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=legacy-cloud-providers;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/legacy-cloud-providers"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/pod-security-admission v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_pod-security-admission = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=pod-security-admission;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/pod-security-admission"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/apiextensions-apiserver v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_apiextensions-apiserver = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=apiextensions-apiserver;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/apiextensions-apiserver"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/kube-controller-manager v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_kube-controller-manager = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=kube-controller-manager;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/kube-controller-manager"

# [go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc v0.35.0] git ls-remote https://github.com/open-telemetry/opentelemetry-go-contrib c4876c33a8e2e4b09501013f3543153d8aa10178
SRCREV_otelgrpc = "c4876c33a8e2e4b09501013f3543153d8aa10178"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-go-contrib;name=otelgrpc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"

# [github.com/k3s-io/kubernetes/staging/src/k8s.io/dynamic-resource-allocation v1.27.15-k3s1] git ls-remote https://github.com/k3s-io/kubernetes 2ada0ef854760bf8058899ab6439837a1f7c1463
SRCREV_dynamic-resource-allocation = "2ada0ef854760bf8058899ab6439837a1f7c1463"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=dynamic-resource-allocation;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/dynamic-resource-allocation"

# [go.opentelemetry.io/contrib/instrumentation/github.com/emicklei/go-restful/otelrestful v0.35.0] git ls-remote https://github.com/open-telemetry/opentelemetry-go-contrib c4876c33a8e2e4b09501013f3543153d8aa10178
SRCREV_otelrestful = "c4876c33a8e2e4b09501013f3543153d8aa10178"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-go-contrib;name=otelrestful;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/contrib/instrumentation/github.com/emicklei/go-restful/otelrestful"

