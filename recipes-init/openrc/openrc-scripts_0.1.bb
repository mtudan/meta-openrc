LICENSE = "GPLv2"

SRC_URI = " \
    file://busybox-syslogd.initd \
    file://busybox-syslogd.confd \
    file://connman.initd \
    file://connman.confd \
"

# List of services to add to the default runlevel
DEFAULT_SERVICES = " \
    busybox-syslogd \
    connman \
"

do_install() {
    install -d -m 755 ${D}${sysconfdir}init.d
    install -d -m 755 ${D}${sysconfdir}conf.d

    for svc in connman busybox-syslogd; do
        install -m 755 ${svc}.initd ${D}${sysconfdir}init.d/${svc}
        install -m 644 ${svc}.confd ${D}${sysconfdir}conf.d/${svc}
    done

    for svc in ${DEFAULT_SERVICES}; do
        ln -s /etc/init.d/${svc} ${D}${sysconfdir}runlevels/default/${svc}
    done
}


