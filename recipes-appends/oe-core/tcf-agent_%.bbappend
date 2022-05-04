FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://tcf-agent.initd file://tcf-agent.confd"

inherit openrc

do_install:append() {
    openrc_install_initd ${WORKDIR}/tcf-agent.initd
    openrc_install_confd ${WORKDIR}/tcf-agent.confd
}
