STAGES_RES = []
OEBUILD_DIR = "/home/jenkins/oebuild_workspace"

def downloadEmbeddedCI(String remote_url, String branch){
    sh 'rm -rf embedded-ci'
    sh "git clone ${remote_url} -b ${branch} -v embedded-ci --depth=1"
}

def downloadYoctoWithBranch(String workspace, String namespace, String repo, String branch, Integer deepth){
    sh """
        python3 main.py clone_repo \
        -w ${workspace} \
        -r https://gitee.com/${namespace}/${repo} \
        -p ${repo} \
        -v ${branch} \
        -dp ${deepth}
    """
}

def downloadYoctoWithPr(String workspace, String namespace, String repo, Integer prnum, Integer deepth){
    sh """
        python3 main.py clone_repo \
        -w ${workspace} \
        -r https://gitee.com/${namespace}/${repo} \
        -p ${repo} \
        -pr ${prnum} \
        -dp ${deepth}
    """
}

def formatRes(String name, String action, String check_res, String log_path){
    return sh (script: """
        python3 main.py serial \
            -c name=${name} \
            -c action=${action} \
            -c result=${check_res} \
            -c log_path=${log_path}
    """, returnStdout: true).trim()
}

def deleteBuildDir(String build_dir){
    sh """
        rm -rf ${build_dir}
    """
}

def getRandomStr(){
    return sh(script: """
        cat /proc/sys/kernel/random/uuid
    """, returnStdout: true).trim()
}

def mkdirOpeneulerLog(){
    def logdir = "openeuler/log"
    sh "mkdir -p ${logdir}"
    return logdir
}

def getNowDatetime(){
    return sh(script: """
        date "+%Y%m%d%H%M%S"
    """, returnStdout: true).trim()
}

def uploadImageWithKey(String remote_ip, String remote_dir, String username, String remote_key, String local_dir){
    sh """
        python3 main.py put_to_dst \
        -t 0 \
        -ld ${local_dir} \
        -dd ${remote_dir} \
        -i ${remote_ip} \
        -u ${username} \
        -k ${remote_key} \
        -sign \
        -d
    """
}

def putSStateCacheToDst(String local_dir, String dst_dir){
    sh """
        python3 main.py put_to_dst \
        -t 1 \
        -dd ${dst_dir} \
        -ld ${local_dir}
    """
}

def handleAfterBuildImage(String stage_name, String arch, Integer build_res_code, String log_dir, String random_str, String image_date){
    def build_res = "failed"
    def test_res = "failed"
    def test_res_code = 1
    if (build_res_code == 0){
        build_res = "success"
        if (putToRemote == true){
            // put the image to remote server
            def remote_dir = remoteDir+"/${arch}/${stage_name}"
            def local_dir = "${OEBUILD_DIR}/build/${stage_name}/output/${image_date}/"
            uploadImageWithKey(remoteIP, remote_dir, remoteUname, remoteKey, local_dir)
        }
        if (saveSstateCache == true){
            // put sstate-cache to share disk
            // Due to the current sstate-cache containing soft links pointing to files in
            // sstate_origin_dir, we first copy it to a temporary folder (during copying,
            // soft links are defaulted to copy the actual files they point to), then delete
            // the source folder, and finally perform an mv operation.
            def sstate_local_dir = "${OEBUILD_DIR}/build/${stage_name}/sstate-cache"
            def sstate_dst_dir = "${shareDir}/${ciBranch}/sstate-cache/${stage_name}-temp"
            putSStateCacheToDst(sstate_local_dir, sstate_dst_dir)
            def sstate_origin_dir = "${shareDir}/${ciBranch}/sstate-cache/${stage_name}"
            sh (script: """
                rm -rf ${sstate_origin_dir}
                mv ${sstate_dst_dir} ${sstate_origin_dir}
            """
            )
        }
        // Test the build artifacts of the QEMU image and x86 image.
        if(stage_name.contains("qemu") && stage_name.contains("x86-64") && !stage_name.contains("riscv")){
            test_res_code = sh (script: """
                python3 main.py utest \
                -target openeuler_image \
                -a ${arch} \
                -td ${OEBUILD_DIR}/build/${stage_name} \
                -tm ${mugenRemote} \
                -tb ${mugenBranch} > ${log_dir}/Test-${stage_name}-${random_str}.log
            """, returnStatus: true)
            if (test_res_code == 0){
                test_res = "success"
            }
        }
    }
    // Check the assignment
    archiveArtifacts "${log_dir}/*.log"
    STAGES_RES.push(formatRes(stage_name, "build", build_res, "artifact/${log_dir}/Build-${stage_name}-${random_str}.log"))
    if (build_res_code == 0 && (stage_name.contains("qemu") && stage_name.contains("x86-64") && !stage_name.contains("riscv"))){
        STAGES_RES.push(formatRes(stage_name, "test", test_res, "artifact/${log_dir}/Test-${stage_name}-${random_str}.log"))
    }
}

def prepareSrcCode(workspace){
    sh """
        if [[ -f "${shareDir}/${ciBranch}/src.tar.gz" ]]; then
            pushd ${workspace}
            oebuild init oebuild_workspace
            cd oebuild_workspace
            rm -rf build
            cp -f ${shareDir}/${ciBranch}/src.tar.gz .
            tar zxf src.tar.gz
            popd
        fi
    """
}

// dynamic invoke build image function
def dynamicBuild(image_name, image_date, log_dir, random_str){
    image_name = image_name.replace("-", "_")
    "build_${image_name}"(image_date, log_dir, random_str)
}

// Perform the compilation check for the ok3588 image.
def build_ok3588(image_date, log_dir, random_str){
    def stage_name = "ok3588"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p ok3588 \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the ok3568 image.
def build_ok3568(image_date, log_dir, random_str){
    def stage_name = "ok3568"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p ok3568 \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the qemu-aarch64-ros-mcs image.
def build_qemu_aarch64_ros_mcs(image_date, log_dir, random_str){
    def stage_name = "qemu-aarch64-ros-mcs"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p qemu-aarch64 \
        -f "openeuler-ros;openeuler-mcs;openeuler-container" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the qemu-aarch64-llvm image.
def build_qemu_aarch64_llvm(image_date, log_dir, random_str){
    def stage_name = "qemu-aarch64-llvm"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p qemu-aarch64 \
        -f "clang" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}                                

//Perform the compilation check for the raspberrypi4-64-llvm image.
def build_raspberrypi4_64_llvm(image_date, log_dir, random_str){
    def stage_name = "raspberrypi4-64-llvm"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p raspberrypi4-64 \
        -f "clang;openeuler-container" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the qemu-aarch64-kernel6 image.
def build_qemu_aarch64_kernel6(image_date, log_dir, random_str){
    def stage_name = "qemu-aarch64-kernel6"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p qemu-aarch64 \
        -f "kernel6;openeuler-container" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the raspberrypi4-64 image.
def build_raspberrypi4_64(image_date, log_dir, random_str){
    def stage_name = "raspberrypi4-64"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p raspberrypi4-64 \
        -f "openeuler-container" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)                                  
}

//Perform the compilation check for the raspberrypi4-64-kernel6 image.
def build_raspberrypi4_64_kernel6(image_date, log_dir, random_str){
    def stage_name = "raspberrypi4-64-kernel6"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p raspberrypi4-64 \
        -f "kernel6;openeuler-container" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the qemu-aarch64-kernel6-llvm image.
def build_qemu_aarch64_kernel6_llvm(image_date, log_dir, random_str){
    def stage_name = "qemu-aarch64-kernel6-llvm"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p qemu-aarch64 \
        -f "kernel6;clang;openeuler-container" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d $stage_name > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the raspberrypi4-64-kernel6-llvm image.
def build_raspberrypi4_64_kernel6_llvm(image_date, log_dir, random_str){
    def stage_name = "raspberrypi4-64-kernel6-llvm"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p raspberrypi4-64 \
        -f "kernel6;clang;openeuler-container" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the raspberrypi4-64-rt-hmi image.
def build_raspberrypi4_64_rt_hmi(image_date, log_dir, random_str){
    def stage_name = "raspberrypi4-64-rt-hmi"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p raspberrypi4-64 \
        -f "openeuler-rt;hmi;openeuler-container" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the raspberrypi4-64-kernel6-rt-hmi image.
def build_raspberrypi4_64_kernel6_rt_hmi(image_date, log_dir, random_str){
    def stage_name = "raspberrypi4-64-kernel6-rt-hmi"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p raspberrypi4-64 \
        -f "openeuler-rt;hmi;kernel6;openeuler-container" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the hieulerpi1 image.
def build_hieulerpi1(image_date, log_dir, random_str){
    def stage_name = "hieulerpi1"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p hieulerpi1 \
        -f "openeuler-container" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date}} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the hieulerpi1-tiny image.
def build_hieulerpi1_tiny(image_date, log_dir, random_str){
    def stage_name = "hieulerpi1-tiny"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p hieulerpi1 \
        -i "openeuler-image-tiny" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the hieulerpi1-ros image.
def build_hieulerpi1_ros(image_date, log_dir, random_str){
    def stage_name = "hieulerpi1-ros"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p hieulerpi1 \
        -f "openeuler-ros;openeuler-container" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the qemu-arm image.
def build_qemu_arm(image_date, log_dir, random_str){
    def stage_name = "qemu-arm"
    def arch = "arm"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm32le \
        -p qemu-arm \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the qemu-riscv64 image.
def build_qemu_riscv64(image_date, log_dir, random_str){
    def stage_name = "qemu-riscv64"
    def arch = "riscv64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_riscv64 \
        -p qemu-riscv64 \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the x86-64-rt-hmi-ros-mcs image.
def build_x86_64_rt_hmi_ros_mcs(image_date, log_dir, random_str){
    def stage_name = "x86-64-rt-hmi-ros-mcs"
    def arch = "x86-64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_x86_64 \
        -p x86-64 \
        -f "openeuler-rt;hmi;openeuler-ros;openeuler-mcs" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the x86-64-kernel6-rt-hmi-ros-mcs image.
def build_x86_64_kernel6_rt_hmi_ros_mcs(image_date, log_dir, random_str){
    def stage_name = "x86-64-kernel6-rt-hmi-ros-mcs"
    def arch = "x86-64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_x86_64 \
        -p x86-64 \
        -f "kernel6;openeuler-rt;hmi;openeuler-ros;openeuler-mcs" \
        -i "openeuler-image;openeuler-image -c do_populate_sdk" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the qemu-aarch64 image.
def build_qemu_aarch64(image_date, log_dir, random_str){
    def stage_name = "qemu-aarch64"
    def arch = "aarch64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_arm64le \
        -p qemu-aarch64 \
        -f "openeuler-container" \
        -i "openeuler-image" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

//Perform the compilation check for the x86-64 image.
def build_x86_64(image_date, log_dir, random_str){
    def stage_name = "x86-64"
    def arch = "x86-64"
    def task_res_code = sh (script: """
        python3 main.py build \
        -c /home/jenkins/agent/yocto-meta-openeuler \
        -target openeuler_image \
        -a ${arch} \
        -t /usr1/openeuler/gcc/openeuler_gcc_x86_64 \
        -p x86-64 \
        -i "openeuler-image" \
        -oe "\\-\\-no_layer" \
        -dt ${image_date} \
        -d ${stage_name} > ${log_dir}/Build-${stage_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(stage_name, arch, task_res_code, log_dir, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + stage_name)
}

return this
