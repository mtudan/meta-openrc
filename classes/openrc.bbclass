openrc_install_script() {
    local svc
    local path

    [ ! -d ${D}${OPENRC_INITDIR} ] && install -d ${D}${OPENRC_INITDIR}

    for path in $*; do
        svc=$(basename ${path%\.initd})
        # Not executable, see do_package_qa:append
        install -m 644 ${path} ${D}${OPENRC_INITDIR}/${svc}
    done
}

# For now, openrc is being provided as an alternative to either systemd or the
# regualr sysvint in upstream OE.  Openrc init scripts are being added either
# in the lump openrc-scripts package or by bbappending various upstream
# recipes.  However, file-rdeps doesn't know that having openrc is completely
# optional and will pick up on the shebang in each init script.  The real
# solution is to build off of distro features and update file-rdeps to ignore
# openrc-run, but until then, this works by adding the executable bit back to
# openrc scripts after file-rdeps has done its thing.
python do_package_restore_exec() {
    pkgdest = d.getVar('PKGDEST')
    packages = set((d.getVar('PACKAGES') or '').split())
    initdir = d.getVar('OPENRC_INITDIR')

    for pkg in packages:
        openrcdir = os.path.realpath(os.path.join(pkgdest, pkg) + initdir)
        if not os.path.isdir(openrcdir):
            continue

        for f in os.listdir(openrcdir):
            path = os.path.join(openrcdir, f)
            if os.path.islink(path) or not os.path.isfile(path):
                continue

            with open(path, 'r') as fp:
                shebang = fp.readline().strip()
            if shebang == '#!/sbin/openrc-run':
                os.chmod(path, 0o0755)
}
addtask do_package_restore_exec after do_package_qa before do_package_write_deb do_package_write_ipk do_package_write_rpm
do_package_restore_exec[depends] += "virtual/fakeroot-native:do_populate_sysroot"
do_package_restore_exec[fakeroot] = "1"
