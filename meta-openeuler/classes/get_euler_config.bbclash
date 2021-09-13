python set_rpmdeps() {
    import subprocess
    configfile = d.getVar('EULER_CONFIG_FILE', True)
    if not configfile:
        oeroot = d.getVar('COREBASE', True)
        euler_meta = os.path.join(os.path.abspath(os.path.dirname(oeroot)), "meta-openeuler")
        d.setVar('DL_DIR', os.path.abspath(os.path.dirname(oeroot)))
        rpmdeps  = subprocess.Popen('rpm --eval="%{_rpmconfigdir}"', shell=True, stdout=subprocess.PIPE)
        stdout, stderr = rpmdeps.communicate()
        d.setVar('RPMDEPS', os.path.join(str(stdout, "utf-8").strip(), "rpmdeps"))
        #bb.warn("xxxxxxxxxxxxxxxxxx  xxxxRPMDEPS=%s"%d.getVar('RPMDEPS', True))
}

addhandler set_rpmdeps
set_rpmdeps[eventmask] = "bb.event.RecipePreFinalise"
