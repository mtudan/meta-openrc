FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/inittab ${D}${sysconfdir}/inittab

    [ -n "${OPENRC_VTS}" ] && echo >> ${D}${sysconfdir}/inittab
    for n in ${OPENRC_VTS}; do
        echo "c${n}:12345:respawn:${OPENRC_GETTY} ${OPENRC_VT_GETTY_ARGS} tty${n} linux" \
            >> ${D}${sysconfdir}/inittab
    done

    [ -n "${OPENRC_SERIAL_CONSOLES}" ] && echo >> ${D}${sysconfdir}/inittab
    local i=0
    for dev in ${OPENRC_SERIAL_CONSOLES}; do
        echo "s${i}:12345:respawn:${OPENRC_GETTY} ${OPENRC_SERIAL_CONSOLE_GETTY_ARGS} ${dev} xterm" \
            >> ${D}${sysconfdir}/inittab
        i=`expr ${i} + 1`
    done
}

