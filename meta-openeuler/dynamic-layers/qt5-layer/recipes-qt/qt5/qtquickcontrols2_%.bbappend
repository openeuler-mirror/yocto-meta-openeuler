require qt5-src.inc

SRC_URI:prepend = " \
    file://0001-Unset-mouseGrabberPopup-if-it-s-removed-from-childre.patch \
    file://0002-Ensure-we-don-t-crash-when-changing-sizes-after-clea.patch \
    file://0003-Fix-scroll-bars-not-showing-up-when-binding-to-stand.patch \
    file://0004-implement-a11y-pressing-of-qquickabstractbutton.patch \
    file://0005-Fix-the-popup-position-of-a-Menu.patch \
    file://0006-Accessibility-respect-value-in-attached-Accessible-i.patch \
"

