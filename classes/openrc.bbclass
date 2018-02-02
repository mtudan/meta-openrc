openrc_install_script() {
    local svc

    [ ! -d ${D}${OPENRC_INITDIR} ] && install -d ${D}${OPENRC_INITDIR}

    for svc in $*; do
        install -m 755 ${svc} ${D}${OPENRC_INITDIR}/${svc%\.initd}
    done
}

_add_to_runlevel() {
    local runlevel=$1
    local svc

    shift

    [ ! -d ${D}${sysconfdir}/runlevels/${runlevel} ] \
        && install -d ${D}${sysconfdir}/runlevels/${runlevel}

    for svc in $*; do
        ln -s ${OPENRC_INITDIR}/${svc} ${D}${sysconfdir}/runlevels/${runlevel}
    done

}

openrc_add_to_default_runlevel() {
    _add_to_runlevel default $*
}

openrc_add_to_boot_runlevel() {
    _add_to_runlevel boot $*
}


