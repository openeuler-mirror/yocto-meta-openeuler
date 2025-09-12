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
        env.isUploadLog = "true"
    }
    if (env.openEulerLogRemoteIP == null || env.openEulerLogRemoteIP == ""){
        env.openEulerLogRemoteIP = "39.155.145.68"
    }
    if (env.openEulerLogRemotePort == null || env.openEulerLogRemotePort == ""){
        env.openEulerLogRemotePort = "22"
    }
    if (env.openEulerLogRemoteUser == null || env.openEulerLogRemoteUser == ""){
        env.openEulerLogRemoteUser = "root"
    }
    if (env.openEulerLogRemoteId == null || env.openEulerLogRemoteId == ""){
        env.openEulerLogRemoteId = "AF-Logs-Node-secret"
    }
    if (env.openEulerLogCreditType == null || env.openEulerLogCreditType == ""){
        env.openEulerLogCreditType = "UserPwd"
    }
    if (env.openEulerLogRemoteDir == null || env.openEulerLogRemoteDir == ""){
        env.openEulerLogRemoteDir = "/data/logs/embedded-log"
    }
    if (env.openEulerLogRemoteUrl == null || env.openEulerLogRemoteUrl == ""){
        env.openEulerLogRemoteUrl = "https://build-logs.openeuler.openatom.cn:38080/embedded-log"
    }
    // set remote image
    if (env.isUploadImg == null || env.isUploadImg == ""){
        env.isUploadImg = "true"
    }
    if (env.openEulerImgRemoteIP == null || env.openEulerImgRemoteIP == ""){
        env.openEulerImgRemoteIP = "39.155.145.68"
    }
    if (env.openEulerImgRemotePort == null || env.openEulerImgRemotePort == ""){
        env.openEulerImgRemotePort = "22"
    }
    if (env.openEulerImgRemoteUser == null || env.openEulerImgRemoteUser == ""){
        env.openEulerImgRemoteUser = "root"
    }
    if (env.openEulerImgRemoteId == null || env.openEulerImgRemoteId == ""){
        env.openEulerImgRemoteId = "AF-Logs-Node-secret"
    }
    if (env.openEulerImgCreditType == null || env.openEulerImgCreditType == ""){
        env.openEulerImgCreditType = "UserPwd"
    }
    if (env.openEulerImgRemoteDir == null || env.openEulerImgRemoteDir == ""){
        env.openEulerImgRemoteDir = "/data/logs/packages/master"
    }
    if (env.openEulerImgRemoteUrl == null || env.openEulerImgRemoteUrl == ""){
        env.openEulerImgRemoteUrl = "https://build-logs.openeuler.openatom.cn:38080/packages"
    }
    // set comment
    if (env.isComment == null || env.isComment == ""){
        env.isComment = "true"
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
        env.baseImgUrl = "https://build-logs.openeuler.openatom.cn:38080/packages/master"
    }
    if (env.targetImgUrl == null || env.targetImgUrl == ""){
        env.targetImgUrl = "http://121.36.84.172/dailybuild/EBS-openEuler-Mainline/embedded_img"
    }
    if (env.archList == null || env.archList == ""){
        env.archList = "aarch64 arm32 x86-64 riscv64"
    }

    // gate environment param
    if (env.jenkinsId == null || env.jenkinsId == ""){

    }
}

return this
