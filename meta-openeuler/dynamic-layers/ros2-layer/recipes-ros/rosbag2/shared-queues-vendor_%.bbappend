
# because for zip file, there is no option similar to --strip-components in tar command, so striplevel doesn't work
# so we need some handling for the src dir
do_rename_folder() {
    # concurrentqueue-8f65a8734d77c3cc00d74c0532efca872931d3ce comes from ef7dfbf553288064347d51b8ac335f1ca489032a.zip
    # do not forget to change when ef7dfbf553288064347d51b8ac335f1ca489032a.zip changes
    if [! -d ${WORKDIR}/git/concurrentqueue-8f65a8734d77c3cc00d74c0532efca872931d3ce ] ; then
        mv ${WORKDIR}/git/concurrentqueue-8f65a8734d77c3cc00d74c0532efca872931d3ce ${WORKDIR}/git/concurrentqueue-upstream
    fi
    # readerwriterqueue-ef7dfbf553288064347d51b8ac335f1ca489032a comes from 8f65a8734d77c3cc00d74c0532efca872931d3ce.zip
    # do not forget to change when 8f65a8734d77c3cc00d74c0532efca872931d3ce.zip changes
    if [! -d ${WORKDIR}/git/readerwriterqueue-ef7dfbf553288064347d51b8ac335f1ca489032a ] ; then
        mv ${WORKDIR}/git/readerwriterqueue-ef7dfbf553288064347d51b8ac335f1ca489032a ${WORKDIR}/git/singleproducerconsumer-upstream
    fi
}

addtask rename_folder after do_unpack before do_patch

LIC_FILES_CHKSUM = "file://package.xml;beginline=12;endline=12;md5=12c26a18c7f493fdc7e8a93b16b7c04f"
