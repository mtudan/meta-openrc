OPENRC_PACKAGES ?= "${PN}"

OPENRC_ADD_DEFAULT ?= ""

openrc_install_script() {
    local svc

    [ ! -d ${D}${OPENRC_INITDIR} ] && install -d ${D}${OPENRC_INITDIR}

    for svc in $*; do
        install -m 755 ${svc} ${D}${OPENRC_INITDIR}/${svc%\.initd}
    done
}

openrc_add_to_default_runlevel() {
    local svc

    [ ! -d ${D}${sysconfdir}/runlevels/default ] \
        && install -d ${D}${sysconfdir}/runlevels/default

    for svc in $*; do
        ln -s ${OPENRC_INITDIR}/${svc} ${D}${sysconfdir}/runlevels/default
    done
}

