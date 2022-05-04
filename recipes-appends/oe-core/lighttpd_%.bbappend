FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://lighttpd.initd file://lighttpd.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${WORKDIR}/lighttpd.initd
    openrc_install_confd ${WORKDIR}/lighttpd.confd
}
