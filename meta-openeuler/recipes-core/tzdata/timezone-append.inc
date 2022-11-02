PV = "2022a"

DL_DIR = "${OPENEULER_SP_DIR}/tzdata"

# files, patches that come from openeuler
SRC_URI = " \
        file://tzcode${PV}.tar.gz;name=tzcode \
        file://tzdata${PV}.tar.gz;name=tzdata \
        file://backport-Iran-will-stop-DST-in-2023.patch \
        file://backport-Chile-s-DST-is-delayed-by-a-week-in-September-2022.patch \
        file://backport-Palestine-transitions-are-now-Saturdays-at-02-00.patch \
      	file://backport-Syria-to-switch-from-02-03-with-DST-to-plain-03.patch \
        file://backport-Tweak-expression-of-Palestine-transition.patch \
        file://bugfix-0001-add-Beijing-timezone.patch \
        file://remove-country-selection-from-tzselect-steps.patch \
        file://remove-ROC-timezone.patch \
        file://rename-Macau-to-Macao.patch \
        file://remove-El_Aaiun-timezone.patch \
        file://remove-Israel-timezone.patch \
        file://skip-check_web-testcase.patch \
	file://backport-Jordan-to-switch-from-02-03-with-DST-to-plain-03.patch \
        "

SRC_URI[tzcode.sha256sum] = "f8575e7e33be9ee265df2081092526b81c80abac3f4a04399ae9d4d91cdadac7"
SRC_URI[tzdata.sha256sum] = "ef7fffd9f4f50f4f58328b35022a32a5a056b245c5cb3d6791dddb342f871664"
