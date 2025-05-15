PV = "2.9.27"

OPENEULER_LOCAL_NAME = "ansible"
SRC_URI[sha256sum] = "479159e50b3bd90920d06bc59410c3a51d3f9be9b4e1029e11d1e4a2d0705736"

# From src-openeuler
SRC_URI = " \
        file://ansible-${PV}.tar.gz \
        file://ansible-2.9.22-rocky.patch \
        file://ansible-2.9.6-disable-test_build_requirement_from_path_no_version.patch \
        file://fix-python-3.9-compatibility.patch \
        file://ansible-2.9.23-sphinx4.patch \
        file://hostname-module-support-openEuler.patch \
        file://Fix-build-error-for-sphinx-7.0.patch \
        file://CVE-2024-0690.patch \
        file://CVE-2024-8775.patch \
        file://CVE-2024-9902.patch \
        file://CVE-2022-3697.patch \
        file://CVE-2023-5115.patch \
        file://CVE-2023-5764.patch \
"

do_install:append() {
    # For openeuler, we need to gather machine's information to support oedeploy.
    sed -i "s|^gathering = explicit|#gathering = implicit|g" \
        ${D}/${sysconfdir}/ansible/ansible.cfg
}
