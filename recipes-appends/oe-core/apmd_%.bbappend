FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://apmd.initd file://apmd.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${WORKDIR}/apmd.initd
    openrc_install_confd ${WORKDIR}/apmd.confd
}
