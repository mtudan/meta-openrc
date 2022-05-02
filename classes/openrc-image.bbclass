# Add services to the specified runlevel
#
# @param    - Filesystem root
# @param    - Runlevel name
# @params   - Services to add to default runlevel
openrc_add_to_runlevel() {
    local destdir=$1
    local runlevel=$2
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
    local dest=$1
    shift
    openrc_add_to_runlevel ${dest} default $*
}

# Add services to the boot runlevel
#
# @param    - Filesystem root
# @params   - Services to add to boot runlevel
openrc_add_to_boot_runlevel() {
    local dest=$1
    shift
    openrc_add_to_runlevel ${dest} boot $*
}

# Stack a runlevel inside another
#
# @param    - Filesystem root
# @param    - Parent runlevel
# @param    - Runlevel to add to the parent.
openrc_stack_runlevel() {
    local destdir=$1
    local parent=$2
    local src=$3

    if ! echo ${destdir} | grep -q "^/"; then
        bbfatal "Destination '${destdir}' does not look like a path"
    fi

    if [ ! -d ${destdir}${sysconfdir}/runlevels/${src} ]; then
        bbfatal "Source runlevel '${src}' does not exist"
    fi

    [ ! -d ${destdir}${sysconfdir}/runlevels/${parent} ] \
        && install -d ${destdir}${sysconfdir}/runlevels/${parent}

    ln -snf ../${src} ${destdir}${sysconfdir}/runlevels/${parent}/
}

# Like oe-core/meta/classes/rootfs-postcommands, allow dropbear to accept
# logins from accounts with an empty password string if debug-tweaks or
# allow-empty-password is enabled.
ROOTFS_POSTPROCESS_COMMAND += "${@bb.utils.contains_any('IMAGE_FEATURES', ['debug-tweaks', 'allow-empty-password'], 'openrc_ssh_allow_empty_password; ', '', d)}"

openrc_ssh_allow_empty_password() {
    local confd=${IMAGE_ROOTFS}${OPENRC_CONFDIR}/dropbear

    if [ ! -s "${confd}" ]; then
        echo 'COMMAND_ARGS="-B"' > ${confd}
    else
        if ! grep '^COMMAND_ARGS=".*-B[ \t"]' ${confd}; then
            # Add -B, Allow blank password logins
            sed -i 's,COMMAND_ARGS="\([^"]*\)",COMMAND_ARGS="\1 -B",' ${confd}
        fi

        # Remove -w, Disallow root logins
        sed -i 's,-w\([ \t"]\),\1,' ${confd}
    fi
}
