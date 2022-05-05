FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://rpcbind.initd file://rpcbind.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${WORKDIR}/rpcbind.initd
    openrc_install_confd ${WORKDIR}/rpcbind.confd
}
