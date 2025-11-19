export sites="k8s.io/utils:k8s.io/utils:force \
           golang.org/x/net:golang.org/x/net:force \
           golang.org/x/sys:golang.org/x/sys:force \
           gopkg.in/yaml.v2:gopkg.in/yaml.v2:force \
           inet.af/tcpproxy:inet.af/tcpproxy:force \
           sigs.k8s.io/yaml:sigs.k8s.io/yaml:force \
           k8s.io/klog:github.com/k3s-io/klog:force \
           github.com/lib/pq:github.com/lib/pq:force \
           golang.org/x/crypto:golang.org/x/crypto:force \
           k8s.io/klog/v2:github.com/k3s-io/klog/v2:force \
           github.com/pkg/errors:github.com/pkg/errors:force \
           github.com/urfave/cli:github.com/urfave/cli:force \
           github.com/google/uuid:github.com/google/uuid:force \
           github.com/gorilla/mux:github.com/gorilla/mux:force \
           github.com/k3s-io/kine:github.com/k3s-io/kine:force \
           github.com/onsi/ginkgo:github.com/onsi/ginkgo:force \
           github.com/onsi/gomega:github.com/onsi/gomega:force \
           github.com/spf13/pflag:github.com/spf13/pflag:force \
           google.golang.org/grpc:google.golang.org/grpc:force \
           k8s.io/kubernetes:github.com/k3s-io/kubernetes:force \
           github.com/otiai10/copy:github.com/otiai10/copy:force \
           github.com/docker/docker:github.com/docker/docker:force \
           github.com/rancher/lasso:github.com/rancher/lasso:force \
           github.com/robfig/cron/v3:github.com/robfig/cron/v3:force \
           github.com/google/cadvisor:github.com/google/cadvisor:force \
           github.com/rancher/wharfie:github.com/rancher/wharfie:force \
           github.com/sirupsen/logrus:github.com/sirupsen/logrus:force \
           github.com/mattn/go-sqlite3:github.com/mattn/go-sqlite3:force \
           github.com/rancher/wrangler:github.com/rancher/wrangler:force \
           github.com/stretchr/testify:github.com/stretchr/testify:force \
           go.etcd.io/etcd/api/v3:github.com/k3s-io/etcd/api/v3/api:force \
           github.com/Microsoft/hcsshim:github.com/Microsoft/hcsshim:force \
           github.com/coreos/go-systemd:github.com/coreos/go-systemd:force \
           github.com/gorilla/websocket:github.com/gorilla/websocket:force \
           github.com/minio/minio-go/v7:github.com/minio/minio-go/v7:force \
           github.com/tchap/go-patricia:github.com/tchap/go-patricia:force \
           github.com/containerd/cgroups:github.com/containerd/cgroups:force \
           github.com/coreos/go-iptables:github.com/coreos/go-iptables:force \
           github.com/flannel-io/flannel:github.com/flannel-io/flannel:force \
           github.com/golangplus/testing:github.com/golangplus/testing:force \
           github.com/klauspost/compress:github.com/klauspost/compress:force \
           github.com/containerd/containerd:github.com/k3s-io/containerd:force \
           github.com/erikdubbelboer/gspt:github.com/erikdubbelboer/gspt:force \
           github.com/go-sql-driver/mysql:github.com/go-sql-driver/mysql:force \
           github.com/opencontainers/runc:github.com/opencontainers/runc:force \
           github.com/natefinch/lumberjack:github.com/natefinch/lumberjack:force \
           github.com/rancher/remotedialer:github.com/rancher/remotedialer:force \
           github.com/kubernetes-sigs/cri-tools:github.com/k3s-io/cri-tools:force \
           github.com/go-bindata/go-bindata:github.com/go-bindata/go-bindata:force \
           go.etcd.io/etcd/server/v3:github.com/k3s-io/etcd/server/v3/server:force \
           github.com/k3s-io/helm-controller:github.com/k3s-io/helm-controller:force \
           github.com/opencontainers/selinux:github.com/opencontainers/selinux:force \
           go.etcd.io/etcd/client/v3:github.com/k3s-io/etcd/client/v3/client/v3:force \
           go.etcd.io/etcd/etcdutl/v3:github.com/k3s-io/etcd/etcdutl/v3/etcdutl:force \
           github.com/rancher/dynamiclistener:github.com/rancher/dynamiclistener:force \
           github.com/containerd/stargz-snapshotter:github.com/containerd/stargz-snapshotter:force \
           github.com/rootless-containers/rootlesskit:github.com/rootless-containers/rootlesskit:force \
           k8s.io/api:github.com/k3s-io/kubernetes/staging/src/k8s.io/api/staging/src/k8s.io/api:force \
           github.com/containerd/fuse-overlayfs-snapshotter:github.com/containerd/fuse-overlayfs-snapshotter:force \
           k8s.io/cri-api:github.com/k3s-io/kubernetes/staging/src/k8s.io/cri-api/staging/src/k8s.io/cri-api:force \
           k8s.io/kubectl:github.com/k3s-io/kubernetes/staging/src/k8s.io/kubectl/staging/src/k8s.io/kubectl:force \
           k8s.io/apiserver:github.com/k3s-io/kubernetes/staging/src/k8s.io/apiserver/staging/src/k8s.io/apiserver:force \
           k8s.io/client-go:github.com/k3s-io/kubernetes/staging/src/k8s.io/client-go/staging/src/k8s.io/client-go:force \
           k8s.io/apimachinery:github.com/k3s-io/kubernetes/staging/src/k8s.io/apimachinery/staging/src/k8s.io/apimachinery:force \
           k8s.io/cloud-provider:github.com/k3s-io/kubernetes/staging/src/k8s.io/cloud-provider/staging/src/k8s.io/cloud-provider:force \
           k8s.io/code-generator:github.com/k3s-io/kubernetes/staging/src/k8s.io/code-generator/staging/src/k8s.io/code-generator:force \
           k8s.io/component-base:github.com/k3s-io/kubernetes/staging/src/k8s.io/component-base/staging/src/k8s.io/component-base:force \
           k8s.io/controller-manager:github.com/k3s-io/kubernetes/staging/src/k8s.io/controller-manager/staging/src/k8s.io/controller-manager:force"

do_compile:prepend() {
    cd ${S}/src/import
    for s in $sites; do
        site_dest=$(echo $s | cut -d: -f1)
        site_source=$(echo $s | cut -d: -f2)
        force_flag=$(echo $s | cut -d: -f3)

        mkdir -p vendor.copy/$site_dest

        # create a temporary exclude file
        exclude_file=$(mktemp)

        find vendor.fetch/$site_source -type d -print0 |         xargs -0 du -sBM 2>/dev/null |         awk '{if ($1+0 > 500) print substr($0, index($0,$2))}' |         sed 's|^vendor.fetch/||' > "$exclude_file"

        if [ -n "$force_flag" ]; then
            echo "[INFO] $site_dest: force copying .go files"
            rm -rf vendor.copy/$site_dest
            rsync -a                 --exclude='vendor/'                 --exclude='.git/'                 --exclude-from="$exclude_file"                 vendor.fetch/$site_source/ vendor.copy/$site_dest
        else
            if [ -n "$(ls -A vendor.copy/$site_dest/*.go 2> /dev/null)" ]; then
                echo "[INFO] vendor.fetch/$site_source -> $site_dest: go copy skipped (files present)"
                true
            else
                echo "[INFO] $site_dest: copying .go files"
                rsync -a                     --exclude='vendor/'                     --exclude='.git/'                     --exclude-from="$exclude_file"                     vendor.fetch/$site_source/ vendor.copy/$site_dest
            fi
        fi

        rm -f "$exclude_file"
    done
}
