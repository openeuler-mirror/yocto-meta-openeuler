# executed only once
if [ ! -f $OECORE_NATIVE_SYSROOT/flag ];then
    touch $OECORE_NATIVE_SYSROOT/flag

    # adapt to openEuler-Embedded build
    if [[ -f "$OECORE_NATIVE_SYSROOT/usr/bin/meson" ]]; then
        mv $OECORE_NATIVE_SYSROOT/usr/bin/meson $OECORE_NATIVE_SYSROOT/usr/bin/meson.bak
        mv $OECORE_NATIVE_SYSROOT/usr/bin/meson.real $OECORE_NATIVE_SYSROOT/usr/bin/meson
    fi

    if [[ -f "$OECORE_NATIVE_SYSROOT/usr/bin/python3" ]]; then
        ln -s $OECORE_NATIVE_SYSROOT/usr/bin/python3 $OECORE_NATIVE_SYSROOT/usr/bin/python
    fi

    if [[ -f "$OECORE_NATIVE_SYSROOT/usr/lib/rpm/rpmdeps" ]]; then
        sed -i 's|/../lib/rpm|/../../lib/rpm|g' $OECORE_NATIVE_SYSROOT/usr/lib/rpm/rpmdeps
    fi
fi
