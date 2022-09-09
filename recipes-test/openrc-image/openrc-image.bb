DESCRIPTION = "Minimal image using openrc"

IMAGE_FEATURES += "ssh-server-dropbear"

IMAGE_INSTALL += " \
    openrc \
    packagegroup-core-boot \
"

IMAGE_BASENAME := "openrc"

inherit core-image openrc-image

# The logging runlevel is just an example that serves to make sure that
# runlevel stacking and adding of services is functioning correctly.
OPENRC_STACKED_RUNLEVELS += "logging:default"
OPENRC_SERVICES += " \
    sysinit:udev-trigger \
    default:udev-settle \
    logging:busybox-klogd \
    logging:busybox-syslogd \
"

boot_to_logging() {
    sed -i '/^l[345]/s,default,logging,' ${IMAGE_ROOTFS}${sysconfdir}/inittab
}
ROOTFS_POSTPROCESS_COMMAND += "${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'boot_to_logging; ', '', d)}"

# vim: ft=bitbake
