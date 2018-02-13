openrc_install_script() {
    local svc
    local path

    [ ! -d ${D}${OPENRC_INITDIR} ] && install -d ${D}${OPENRC_INITDIR}

    for path in $*; do
        svc=$(basename ${path%\.initd})
        install -m 755 ${path} ${D}${OPENRC_INITDIR}/${svc}
    done
}

_openrc_add_to_runlevel() {
    local runlevel=$1
    local destdir=$2
    local svc

    if ! echo ${destdir} | grep -q "^/"; then
        bbfatal "Destination '${destdir}' does not look like a path"
    fi

    shift
    shift

    [ ! -d ${destdir}${sysconfdir}/runlevels/${runlevel} ] \
        && install -d ${destdir}${sysconfdir}/runlevels/${runlevel}

    for svc in $*; do
        ln -snf ${OPENRC_INITDIR}/${svc} ${destdir}${sysconfdir}/runlevels/${runlevel}
    done

}

# Add services to the default runlevel
#
# @param    - Filesystem root
# @params   - Services to add to default runlevel
openrc_add_to_default_runlevel() {
    _openrc_add_to_runlevel default $*
}

# Add services to the boot runlevel
#
# @param    - Filesystem root
# @params   - Services to add to boot runlevel
openrc_add_to_boot_runlevel() {
    _openrc_add_to_runlevel boot $*
}

# Replace the installed inittab with one that uses OpenRC.
#
# @param    - Destination dir where /etc/inittab is already installed.
#             Defaults to ${IMAGE_ROOTFS}.  Note that no consoles are
#             enabled by default, they must be added by appending to
#             etc/inittab.

# TODO:  Just use openrc-init with 0.25
openrc_replace_inittab() {
    local destdir=${1:-${IMAGE_ROOTFS}}

    if [ -z "${destdir}" ]; then
        bbfatal "No destination specified for inittab replacement and not build an image"
    elif [ ! -s "${destdir}${sysconfdir}/inittab" ]; then
        bbwarn "No inittab installed"
    fi

    cat <<-EOF > ${destdir}${sysconfdir}/inittab
		# Default runlevel.
		id:3:initdefault:

		# System initialization, mount local filesystems, etc.
		si::sysinit:/sbin/rc sysinit

		# Further system initialization, brings up the boot runlevel.
		rc::bootwait:/sbin/rc boot

		l0:0:wait:/sbin/rc shutdown
		l0s:0:wait:/sbin/halt -dhp
		l1:1:wait:/sbin/rc single
		l2:2:wait:/sbin/rc nonetwork
		l3:3:wait:/sbin/rc default
		l4:4:wait:/sbin/rc default
		l5:5:wait:/sbin/rc default
		l6:6:wait:/sbin/rc reboot
		l6r:6:wait:/sbin/reboot -d
		#z6:6:respawn:/sbin/sulogin

		# new-style single-user
		su0:S:wait:/sbin/rc single
		su1:S:wait:/sbin/sulogin

		# What to do at the "Three Finger Salute".
		ca:12345:ctrlaltdel:/sbin/shutdown -r now

		# TERMINALS
		# c1:12345:respawn:/sbin/agetty 38400 tty1 linux

		# SERIAL CONSOLES
		#s0:12345:respawn:/sbin/agetty -8 --autologin root --login-pause -L 115200 ttyS0 xterm
		#s1:12345:respawn:/sbin/agetty -L 115200 ttyS1 vt100
	EOF
}
