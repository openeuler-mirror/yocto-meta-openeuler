python set_dldir() {
    import subprocess
    dl_dir = d.getVar('DL_DIR', True)
    oeroot = d.getVar('COREBASE', True)
    srctopdir = os.path.abspath(os.path.dirname(oeroot))
    if not dl_dir or dl_dir == "downloads":
        d.setVar('DL_DIR', srctopdir)
}

addhandler set_dldir
set_dldir[eventmask] = "bb.event.RecipePreFinalise"
