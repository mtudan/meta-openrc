FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://alsa-state.initd"

inherit openrc

do_install:append() {
    sed -i "s,@LOCALSTATEDIR@,${localstatedir},g" ${WORKDIR}/alsa-state.initd
    openrc_install_initd ${WORKDIR}/alsa-state.initd
}
