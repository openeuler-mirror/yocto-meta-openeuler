STAGES_RES = []
OEBUILD_DIR = "/home/jenkins/oebuild_workspace"
AGENT = "/home/jenkins/agent"
LOG_DIR = "openeuler/logs"

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
    dir(AGENT){
        sh "mkdir -p ${LOG_DIR}"
    }
}

def artifactsLogs(){
    dir(AGENT){
        sh "ls -al ${LOG_DIR}"
        archiveArtifacts artifacts: "${LOG_DIR}/*.log", fingerprint: true
    }
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

def uploadLogWithKey(String remote_ip, String remote_dir, String username, String remote_key, String local_path){
    sh """
        scp -i ${remote_key} -o 'StrictHostKeyChecking no' ${local_path} ${username}@${remote_ip}:${remote_dir}
    """
}

def handleLog(log_file){
    log_path = "${LOG_DIR}/${log_file}"
    if (env.isUploadLog != null && env.isUploadLog == "true"){
        withCredentials([
            file(credentialsId: openEulerEmbeddedKey, variable: 'openEulerKey')
        ]){
            def local_log_path = "${AGENT}/${log_path}"
            uploadLogWithKey(openEulerRemoteIP, openEulerLogDir, openEulerRemoteUser, openEulerKey, local_log_path)
        }
        log_path = "${openEulerLogUrl}/${log_file}"
    }else{
        log_path = "artifact/${log_path}"
    }
    return log_path
}

def handleAfterBuildImage(String image_name, String arch, Integer build_res_code, String random_str, String image_date){
    def build_res = "failed"
    def test_res = "failed"
    def test_res_code = 1
    if (build_res_code == 0){
        build_res = "success"
        if (putToRemote == true){
            // put the image to remote server
            def remote_dir = remoteDir+"/${arch}/${image_name}"
            def local_dir = "${OEBUILD_DIR}/build/${image_name}/output/${image_date}/"
            uploadImageWithKey(remoteIP, remote_dir, remoteUname, remoteKey, local_dir)
        }
        if (saveSstateCache == true){
            // put sstate-cache to share disk
            // Due to the current sstate-cache containing soft links pointing to files in
            // sstate_origin_dir, we first copy it to a temporary folder (during copying,
            // soft links are defaulted to copy the actual files they point to), then delete
            // the source folder, and finally perform an mv operation.
            def sstate_local_dir = "${OEBUILD_DIR}/build/${image_name}/sstate-cache"
            def sstate_dst_dir = "${shareDir}/${ciBranch}/sstate-cache/${image_name}-temp"
            putSStateCacheToDst(sstate_local_dir, sstate_dst_dir)
            def sstate_origin_dir = "${shareDir}/${ciBranch}/sstate-cache/${image_name}"
            sh (script: """
                rm -rf ${sstate_origin_dir}
                mv ${sstate_dst_dir} ${sstate_origin_dir}
            """
            )
        }
        // Test the build artifacts of the QEMU image and x86 image.
        if(image_name.contains("qemu") && image_name.contains("x86-64") && !image_name.contains("riscv")){
            test_res_code = sh (script: """
                python3 main.py utest \
                -target openeuler_image \
                -a ${arch} \
                -td ${OEBUILD_DIR}/build/${image_name} \
                -tm ${mugenRemote} \
                -tb ${mugenBranch} > ${AGENT}/${LOG_DIR}/Test-${image_name}-${random_str}.log
            """, returnStatus: true)
            if (test_res_code == 0){
                test_res = "success"
            }
        }
    }

    // if need to upload log to remote
    log_file = "Build-${image_name}-${random_str}.log"
    log_path = handleLog(log_file)
    STAGES_RES.push(formatRes(image_name, "build", build_res, log_path))

    if (build_res_code == 0 && (image_name.contains("qemu") && image_name.contains("x86-64") && !image_name.contains("riscv"))){
        log_file = "Test-${image_name}-${random_str}.log"
        log_path = handleLog(log_file)
        STAGES_RES.push(formatRes(image_name, "test", test_res, log_path))
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

def translateCompileToHost(yocto_dir, arch, image_name){
    def compileContent = readYaml file: "${yocto_dir}/.oebuild/samples/${arch}/${image_name}.yaml"
    compileContent.build_in = "host"
    if (arch == "aarch64"){
        compileContent.toolchain_dir = "/usr1/openeuler/gcc/openeuler_gcc_arm64le"
    }
    if (arch == "arm32"){
        compileContent.toolchain_dir = "/usr1/openeuler/gcc/openeuler_gcc_arm32le"
    }
    if (arch == "riscv64"){
        compileContent.toolchain_dir = "/usr1/openeuler/gcc/openeuler_gcc_riscv64"
    }
    if (arch == "x86-64"){
        compileContent.toolchain_dir = "/usr1/openeuler/gcc/openeuler_gcc_x86_64"
    }
    samples_dir = "/home/jenkins/agent/samples/${arch}"
    sh "mkdir -p ${samples_dir}"
    writeYaml file: "${samples_dir}/${image_name}.yaml", data: compileContent
    return "${samples_dir}/${image_name}.yaml"
}

// dynamic invoke build image function
def dynamicBuild(yocto_dir, arch, image_name, image_date, random_str){
    compile_path = translateCompileToHost(yocto_dir, arch, image_name)
    // prepare oebuild build environment
    def task_res_code = sh (script: """
        oebuild init ${OEBUILD_DIR}
        cd ${OEBUILD_DIR}
        mkdir -p build
        ln -sf ${yocto_dir} src/yocto-meta-openeuler
        oebuild ${compile_path} > ${AGENT}/${LOG_DIR}/Build-${image_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(image_name, arch, task_res_code, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + image_name)
}

return this
