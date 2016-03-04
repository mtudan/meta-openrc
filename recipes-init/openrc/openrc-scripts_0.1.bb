LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

#FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = " \
    file://busybox-syslogd.initd \
    file://busybox-syslogd.confd \
    file://connman.initd \
    file://connman.confd \
    file://dbus.initd \
    file://udev.initd \
"

# List of services to install
SERVICES = " \
    busybox-syslogd \
    connman \
    dbus \
    udev \
"

# List of services to add to the default runlevel
DEFAULT_SERVICES = " \
    busybox-syslogd \
    connman \
    udev \
"

S="${WORKDIR}"

do_compile() {
    :
}

do_install() {
    install -d -m 755 ${D}${OPENRC_INITDIR}
    install -d -m 755 ${D}${OPENRC_CONFDIR}

    for svc in ${SERVICES}; do
        install -m 755 ${svc}.initd ${D}${OPENRC_INITDIR}/${svc}

        if [ -f ${svc}.confd ]; then
            install -m 644 ${svc}.confd ${D}${OPENRC_CONFDIR}/${svc}
        fi
    done

    install -d -m 755 ${D}${sysconfdir}/runlevels/default
    for svc in ${DEFAULT_SERVICES}; do
        ln -s ${OPENRC_INITDIR}/${svc} ${D}${sysconfdir}/runlevels/default
    done
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
RDEPENDS_${PN} = "openrc"

