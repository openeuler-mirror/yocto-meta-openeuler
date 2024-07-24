def init_environment(){
    // set embedded
    if (env.embeddedRemote == null || env.embeddedRemote == ""){
        env.embeddedRemote = "https://gitee.com/openeuler/embedded-ci.git"
    }
    if (env.embeddedBranch == null || env.embeddedBranch == ""){
        env.embeddedBranch = "master"
    }
    // set build repo
    if (env.yoctoRemote == null || env.yoctoRemote == ""){
        env.yoctoRemote = "https://gitee.com/openeuler/yocto-meta-openeuler.git"
    }
    if (env.yoctoBranch == null || env.yoctoBranch == ""){
        env.yoctoBranch = "master"
    }
    // set test mugen
    if (env.isTest == null || env.isTest == ""){
        env.isTest = "false"
    }
    if (env.mugenRemote == null || env.mugenRemote == ""){
        env.mugenRemote = "https://gitee.com/openeuler/mugen.git"
    }
    if (env.mugenBranch == null || env.mugenBranch == ""){
        env.mugenBranch = "master"
    }
    // set remote log
    if (env.isUploadLog == null || env.isUploadLog == ""){
        env.isUploadLog = "false"
    }
    if (env.openEulerLogRemoteIP == null || env.openEulerLogRemoteIP == ""){
        env.openEulerLogRemoteIP = "43.136.114.130"
    }
    if (env.openEulerLogRemoteUser == null || env.openEulerLogRemoteUser == ""){
        env.openEulerLogRemoteUser = "openeuler"
    }
    if (env.openEulerLogRemoteKey == null || env.openEulerLogRemoteKey == ""){
        env.openEulerLogRemoteKey = "openEulerEmbeddedRemoteKey"
    }
    if (env.openEulerLogRemoteDir == null || env.openEulerLogRemoteDir == ""){
        env.openEulerLogRemoteDir = "/var/www/html/openeuler-log"
    }
    if (env.openEulerLogRemoteUrl == null || env.openEulerLogRemoteUrl == ""){
        env.openEulerLogRemoteUrl = "http://43.136.114.130/openeuler-log"
    }
    // set remote image
    if (env.isUploadImg == null || env.isUploadImg == ""){
        env.isUploadImg = "false"
    }
    if (env.openEulerImgRemoteIP == null || env.openEulerImgRemoteIP == ""){
        env.openEulerImgRemoteIP = "43.136.114.130"
    }
    if (env.openEulerImgRemoteUser == null || env.openEulerImgRemoteUser == ""){
        env.openEulerImgRemoteUser = "openeuler"
    }
    if (env.openEulerImgRemoteKey == null || env.openEulerImgRemoteKey == ""){
        env.openEulerImgRemoteKey = "openEulerEmbeddedRemoteKey"
    }
    if (env.openEulerImgRemoteDir == null || env.openEulerImgRemoteDir == ""){
        env.openEulerImgRemoteDir = "/var/www/html/openeuler-ci/master"
    }
    // set comment
    if (env.isComment == null || env.isComment == ""){
        env.isComment = "false"
    }
    if (env.giteeId == null || env.giteeId == ""){
        env.giteeId = "gitee-api-token"
    }
    if (env.commentNameSpace == null || env.commentNameSpace == ""){
        env.commentNameSpace = "openeuler"
    }
    if (env.commentRepo == null || env.commentRepo == ""){
        env.commentRepo = "yocto-embedded-tools"
    }
    if (env.commentRepoBranch == null || env.commentRepoBranch == ""){
        env.commentRepoBranch = "master"
    }
    // set other
    if (env.isSaveCache == null || env.isSaveCache == ""){
        env.isSaveCache = "false"
    }
    if (env.shareDir == null || env.shareDir == ""){
        env.shareDir = "/home/jenkins/ccache"
    }
    if (env.ciBranch == null || env.ciBranch == ""){
        env.ciBranch = "master"
    }
    if (env.parallelNum == null || env.parallelNum == ""){
        env.parallelNum = "5"
    }
    if (env.buildImages == null || env.buildImages == ""){
        env.buildImages = "aarch64/qemu-aarch64 aarch64/hieulerpi1 arm32/qemu-arm riscv/qemu-riscv54 x86-64/x86-64"
    }
    if (env.baseImgUrl == null  || env.baseImgUrl == ""){
        env.baseImgUrl = "http://43.136.114.130/openeuler-ci/master"
    }
    if (env.targetImgUrl == null || env.targetImgUrl == ""){
        env.targetImgUrl = "http://121.36.84.172/dailybuild/EBS-openEuler-Mainline/EBS-openEuler-Mainline/embedded_img"
    }
    if (env.archList == null || env.archList == ""){
        env.archList = "aarch64 arm32 x86-64 riscv64"
    }
}

return this
