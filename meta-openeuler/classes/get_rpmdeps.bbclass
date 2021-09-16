python set_rpmdeps() {
    import subprocess
    rpmdeps = d.getVar('RPMDEPS', True)
    if not rpmdeps or rpmdeps == "default":
        rpmdeps  = subprocess.Popen('rpm --eval="%{_rpmconfigdir}"', shell=True, stdout=subprocess.PIPE)
        stdout, stderr = rpmdeps.communicate()
        d.setVar('RPMDEPS', os.path.join(str(stdout, "utf-8").strip(), "rpmdeps"))
        #bb.warn("xxxxxxxxxxxxxxxxxx  xxxxRPMDEPS=%s"%d.getVar('RPMDEPS', True))
}

addhandler set_rpmdeps
set_rpmdeps[eventmask] = "bb.event.RecipePreFinalise"
