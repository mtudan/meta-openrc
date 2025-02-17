# Define additional services that should be enabled for given runlevels as a
# list of whitespace-separated [runlevel]:[service].
OPENRC_SERVICES ?= " \
    ${@bb.utils.contains('IMAGE_FEATURES', 'ssh-server-dropbear', 'default:dropbear', '', d)} \
    ${@bb.utils.contains('IMAGE_FEATURES', 'ssh-server-openssh', 'default:sshd', '', d)} \
"

# Define stacked runlevels as a whitespace-separated
# [stacked runlevel]:[base runlevel]
OPENRC_STACKED_RUNLEVELS ?= ""

ROOTFS_POSTPROCESS_COMMAND += "${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'openrc_stack_runlevels; openrc_add_services; ', '', d)}"

openrc_stack_runlevels() {
    local stack
    local base
    local stacked

    for stack in ${OPENRC_STACKED_RUNLEVELS}; do
        base=${stack##*:}
        stacked=${stack%%:*}

        [ ! -d ${IMAGE_ROOTFS}${sysconfdir}/runlevels/${stacked} ] \
            && install -d ${IMAGE_ROOTFS}${sysconfdir}/runlevels/${stacked}

        [ ! -d ${IMAGE_ROOTFS}${sysconfdir}/runlevels/${base} ] \
            && install -d ${IMAGE_ROOTFS}${sysconfdir}/runlevels/${base}

        ln -snf ../${base} ${IMAGE_ROOTFS}${sysconfdir}/runlevels/${stacked}/
    done
}

openrc_add_services() {
    local pair
    local runlevel
    local svc

    for pair in ${OPENRC_SERVICES}; do
        runlevel=${pair%%:*}
        svc=${pair##*:}

        if [ ! -f ${IMAGE_ROOTFS}${OPENRC_INITDIR}/${svc} ]; then
            bbfatal "No openrc service named '${svc}' found."
        fi

        [ ! -d ${IMAGE_ROOTFS}${sysconfdir}/runlevels/${runlevel} ] \
            && install -d ${IMAGE_ROOTFS}${sysconfdir}/runlevels/${runlevel}

        ln -snf ${OPENRC_INITDIR}/${svc} ${IMAGE_ROOTFS}${sysconfdir}/runlevels/${runlevel}
    done
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
