PV = "2022a"

OPENEULER_REPO_NAME = "tzdata"

# files, patches that come from openeuler
SRC_URI = " \
        file://tzcode${PV}.tar.gz;name=tzcode \
        file://tzdata${PV}.tar.gz;name=tzdata \
        file://backport-Iran-will-stop-DST-in-2023.patch \
        file://backport-Chile-s-DST-is-delayed-by-a-week-in-September-2022.patch \
        file://backport-Palestine-transitions-are-now-Saturdays-at-02-00.patch \
        file://backport-Tweak-expression-of-Palestine-transition.patch \
        file://backport-Syria-to-switch-from-02-03-with-DST-to-plain-03.patch \
        file://backport-Jordan-to-switch-from-02-03-with-DST-to-plain-03.patch \
        file://backport-Fiji-no-longer-observes-DST.patch \
        file://backport-Most-of-Mexico-will-no-longer-observe-DST.patch \
        file://backport-Most-of-Greenland-stops-clock-changing-after-March.patch \
        file://backport-Treat-1931-changes-in-Mexico-as-DST.patch \
        file://backport-Greenland-change-should-affect-only-America-Nuuk.patch \
        file://backport-The-northern-edge-of-Chihuahua-changes-to-US-rules.patch \
        file://backport-Much-of-Greenland-still-uses-DST-from-2024-on.patch \
        file://backport-Egypt-now-uses-DST-again.patch \
        file://backport-Max-max.patch \
        file://backport-This-year-Morocco-springs-forward-April-23-not-April.patch \
        file://backport-Palestine-no-longer-observes-DST-during-Ramadan.patch \
        file://backport-Greenland-changed-standard-time-already.patch \
        file://backport-Fix-Palestine-predictions-for-2072-through-2075.patch \
        file://backport-Ittoqqortoormiit-America-Scoresbysund-zone-change.patch \
        file://backport-Vostok-was-at-07-and-just-switched-to-05.patch \
        file://backport-Sync-Casey-data-from-timeanddate.com.patch \
        file://backport-Kazakhstan-unifies-on-UTC-5-beginning-2024-03-01.patch \
        file://backport-Palestine-springs-forward-a-week-later-after-Ramadan.patch \
        file://bugfix-0001-add-Beijing-timezone.patch \
        file://remove-country-selection-from-tzselect-steps.patch \
        file://remove-ROC-timezone.patch \
        file://rename-Macau-to-Macao.patch \
        file://remove-El_Aaiun-timezone.patch \
        file://remove-Israel-timezone.patch \
        file://skip-check_web-testcase.patch \
        "

SRC_URI[tzcode.sha256sum] = "f8575e7e33be9ee265df2081092526b81c80abac3f4a04399ae9d4d91cdadac7"
SRC_URI[tzdata.sha256sum] = "ef7fffd9f4f50f4f58328b35022a32a5a056b245c5cb3d6791dddb342f871664"
