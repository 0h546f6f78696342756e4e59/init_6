# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
K_NOUSENAME="yes"
K_NOSETEXTRAVERSION="yes"
K_SECURITY_UNSUPPORTED="1"
K_DEBLOB_AVAILABLE="1"
ETYPE="sources"
inherit kernel-2
detect_version

grsecurity_version=201201302345
compat_wireless_version=3.2-1

DESCRIPTION="Full sources for the Linux kernel including fedora, grsecurity patches"
HOMEPAGE="http://www.kernel.org http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary http://wireless.kernel.org/en/users/Download/stable http://grsecurity.net"
SRC_URI="${KERNEL_URI} ${ARCH_URI} http://grsecurity.net/test/grsecurity-2.2.2-${PV}-${grsecurity_version}.patch http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.2/compat-wireless-${compat_wireless_version}.tar.bz2 http://www.orbit-lab.org/kernel/compat-wireless-2.6/2012/01/compat-wireless-${compat_wireless_version}.tar.bz2"

KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ppc ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="backports branding deblob hardened"

KV_FULL="${KV_FULL/linux/geek}"
EXTRAVERSION="${EXTRAVERSION/linux/geek}"
SLOT="${PV}"
S="${WORKDIR}/linux-${KV_FULL}"

src_unpack() {

	kernel-2_src_unpack
	cd "${S}"

	einfo "Make kernel default configs"
	cp ${FILESDIR}/${PVR}/config-* . || die "cannot copy kernel config";
	cp ${FILESDIR}/${PVR}/merge.pl ${FILESDIR}/${PVR}/Makefile.config . &>/dev/null || die "cannot copy kernel files";
	make -f Makefile.config VERSION=${PVR} configs &>/dev/null || die "cannot generate kernel .config files from config-* files"

	use hardened && epatch ${DISTDIR}/grsecurity-2.2.2-${PV}-${grsecurity_version}.patch

### BRANCH APPLY ###

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-makefile-after_link.patch

# Architecture patches
# x86(-64)

#
# ARM
#
	epatch "${FILESDIR}"/"${PVR}"/arm-omap-dt-compat.patch
	epatch "${FILESDIR}"/"${PVR}"/arm-smsc-support-reading-mac-address-from-device-tree.patch

	epatch "${FILESDIR}"/"${PVR}"/taint-vbox.patch
#
# NX Emulation
#
	use hardened || epatch "${FILESDIR}"/"${PVR}"/linux-2.6-32bit-mmap-exec-randomization.patch
	use hardened || epatch "${FILESDIR}"/"${PVR}"/linux-2.6-i386-nx-emulation.patch

#
# bugfixes to drivers and filesystems
#

# ext4
#rhbz 753346
	epatch "${FILESDIR}"/"${PVR}"/jbd-jbd2-validate-sb-s_first-in-journal_get_superblo.patch

# xfs

# btrfs


# eCryptfs

# NFSv4

# USB

# WMI

# ACPI
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-acpi-video.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-acpi-video-dos.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-acpi-debug-infinite-loop.patch
	epatch "${FILESDIR}"/"${PVR}"/acpi-ensure-thermal-limits-match-cpu-freq.patch
	epatch "${FILESDIR}"/"${PVR}"/acpi-sony-nonvs-blacklist.patch

#
# PCI
#
# enable ASPM by default on hardware we expect to work
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-aspm.patch

#
# SCSI Bits.
#

# ACPI

# ALSA

# Networking


# Misc fixes
# The input layer spews crap no-one cares about.
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-input-kill-stupid-messages.patch

# stop floppy.ko from autoloading during udev...
	epatch "${FILESDIR}"/"${PVR}"/die-floppy-die.patch
	epatch "${FILESDIR}"/"${PVR}"/floppy-drop-disable_hlt-warning.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6.30-no-pcspkr-modalias.patch

# Allow to use 480600 baud on 16C950 UARTs
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-serial-460800.patch

# Silence some useless messages that still get printed with 'quiet'
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-noise.patch

# Make fbcon not show the penguins with 'quiet'
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-fbcon-logo.patch

	# modpost: add option to allow external modules to avoid taint
	use backports epatch "${FILESDIR}"/"${PVR}"/modpost-add-option-to-allow-external-modules-to-avoi.patch

# Changes to upstream defaults.


# /dev/crash driver.
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-crash-driver.patch

# Hack e1000e to work on Montevina SDV
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-e1000-ich9-montevina.patch

# crypto/

# Assorted Virt Fixes
	epatch "${FILESDIR}"/"${PVR}"/fix_xen_guest_on_old_EC2.patch

# DRM core
#	epatch "${FILESDIR}"/"${PVR}"/drm-edid-try-harder-to-fix-up-broken-headers.patch

# Intel DRM
	epatch "${FILESDIR}"/"${PVR}"/drm-i915-fbc-stfu.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-intel-iommu-igfx.patch

# silence the ACPI blacklist code
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-acpi-blacklist.patch
	epatch "${FILESDIR}"/"${PVR}"/quite-apm.patch

# Patches headed upstream

	epatch "${FILESDIR}"/"${PVR}"/disable-i8042-check-on-apple-mac.patch

	epatch "${FILESDIR}"/"${PVR}"/epoll-limit-paths.patch
	epatch "${FILESDIR}"/"${PVR}"/block-stray-block-put-after-teardown.patch

# rhbz#605888
	epatch "${FILESDIR}"/"${PVR}"/dmar-disable-when-ricoh-multifunction.patch

	epatch "${FILESDIR}"/"${PVR}"/revert-efi-rtclock.patch
	epatch "${FILESDIR}"/"${PVR}"/efi-dont-map-boot-services-on-32bit.patch

# utrace.
#	EPATCH_OPTS="-p1 -F1 -s" \
#	epatch "${FILESDIR}"/"${PVR}"/utrace.patch # Failed

#rhbz 752176
	epatch "${FILESDIR}"/"${PVR}"/sysfs-msi-irq-per-device.patch

# rhbz 754907
	epatch "${FILESDIR}"/"${PVR}"/hpsa-add-irqf-shared.patch

	epatch "${FILESDIR}"/"${PVR}"/pci-Rework-ASPM-disable-code.patch

#	epatch "${FILESDIR}"/"${PVR}"/pci-crs-blacklist.patch

#rhbz 717735
#	EPATCH_OPTS="-p1 -F1 -s" \
#	epatch "${FILESDIR}"/"${PVR}"/nfs-client-freezer.patch # Failed

#rhbz 590880
#	EPATCH_OPTS="-p1 -F1 -s" \
#	epatch "${FILESDIR}"/"${PVR}"/alps.patch # Failed

#rhbz 746097
	epatch "${FILESDIR}"/"${PVR}"/tpm_tis-delay-after-aborting-cmd.patch

#rhbz 771058
	epatch "${FILESDIR}"/"${PVR}"/msi-irq-sysfs-warning.patch

	epatch "${FILESDIR}"/"${PVR}"/ext4-Support-check-none-nocheck-mount-options.patch

	epatch "${FILESDIR}"/"${PVR}"/ext4-Fix-error-handling-on-inode-bitmap-corruption.patch

#rhbz 773392
	epatch "${FILESDIR}"/"${PVR}"/KVM-x86-extend-struct-x86_emulate_ops-with-get_cpuid.patch
	epatch "${FILESDIR}"/"${PVR}"/KVM-x86-fix-missing-checks-in-syscall-emulation.patch

#rhbz 728740
	epatch "${FILESDIR}"/"${PVR}"/rtl8192cu-Fix-WARNING-on-suspend-resume.patch

#rhbz 782686
	use hardened || epatch "${FILESDIR}"/"${PVR}"/procfs-parse-mount-options.patch
	use hardened || epatch "${FILESDIR}"/"${PVR}"/procfs-add-hidepid-and-gid-mount-options.patch
	use hardened || epatch "${FILESDIR}"/"${PVR}"/proc-fix-null-pointer-deref-in-proc_pid_permission.patch

	epatch "${FILESDIR}"/"${PVR}"/mac80211-fix-work-removal-on-deauth-request.patch

	epatch "${FILESDIR}"/"${PVR}"/rcu-reintroduce-missing-calls.patch

#rhbz 718790
	epatch "${FILESDIR}"/"${PVR}"/rds-Make-rds_sock_lock-BH-rather-than-IRQ-safe.patch

#rhbz 783211
	epatch "${FILESDIR}"/"${PVR}"/fs-Inval-cache-for-parent-block-device-if-fsync-called-on-part.patch

#rhbz 784345
	epatch "${FILESDIR}"/"${PVR}"/realtek_async_autopm.patch

# END OF PATCH APPLICATIONS

	if use backports; then
		echo
		einfo "Apply compat-wireless patches"
		echo
		unpack compat-wireless-${compat_wireless_version}.tar.bz2
		cd compat-wireless-${compat_wireless_version}

		epatch "${FILESDIR}"/"${PVR}"/compat-wireless-config-fixups.patch
		epatch "${FILESDIR}"/"${PVR}"/compat-wireless-pr_fmt-warning-avoidance.patch
		epatch "${FILESDIR}"/"${PVR}"/compat-wireless-rtl8192cu-Fix-WARNING-on-suspend-resume.patch

	# Pending upstream fixes
		epatch "${FILESDIR}"/"${PVR}"/mac80211-fix-debugfs-key-station-symlink.patch
		epatch "${FILESDIR}"/"${PVR}"/brcmsmac-fix-tx-queue-flush-infinite-loop.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-Use-the-right-headroom-size-for-mesh-mgmt-f.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-fix-work-removal-on-deauth-request.patch
		epatch "${FILESDIR}"/"${PVR}"/b43-add-option-to-avoid-duplicating-device-support-w.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-update-oper_channel-on-ibss-join.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-set-bss_conf.idle-when-vif-is-connected.patch
		epatch "${FILESDIR}"/"${PVR}"/iwlwifi-fix-PCI-E-transport-inta-race.patch

		epatch "${FILESDIR}"/"${PVR}"/ath9k-use-WARN_ON_ONCE-in-ath_rc_get_highest_rix.patch

		epatch "${FILESDIR}"/"${PVR}"/iwlwifi-bz785561.patch

		cd ..
	fi

	epatch "${FILESDIR}"/acpi-ec-add-delay-before-write.patch
	if use branding; then
		epatch "${FILESDIR}"/font-8x16-iso-latin-1-v2.patch
		epatch "${FILESDIR}"/gentoo-larry-logo-v2.patch
	fi

# Unfortunately, it has yet not been ported into 3.0 kernel.
# Check out here for the progress: http://www.kernel.org/pub/linux/kernel/people/edward/reiser4/
# http://sourceforge.net/projects/reiser4/
#	use reiser4 && epatch ${DISTDIR}/reiser4-for-${PV}.patch.bz2

# Install the docs
	nonfatal dodoc "${FILESDIR}/${PVR}"/{README.txt,TODO}

	echo
	einfo "Live long and prosper."
	echo

	einfo "Set extraversion" # manually set extraversion
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile

	einfo "Delete temp files"
	for cfg in {config-*,temp-*,merge.pl}; do
		rm -f $cfg
	done;
}

src_install() {
	local version_h_name="usr/src/linux-${KV_FULL}/include/linux"
	local version_h="${ROOT}${version_h_name}"

	if [ -f "${version_h}" ]; then
		einfo "Discarding previously installed version.h to avoid collisions"
		addwrite "/${version_h_name}"
		rm -f "${version_h}"
	fi

	kernel-2_src_install
}

pkg_postinst() {
	einfo "Now is the time to configure and build the kernel."
	if use branding; then
		einfo "branding enable"
		einfo "font - CONFIG_FONT_ISO_LATIN_1_8x16 http://sudormrf.wordpress.com/2010/10/23/ka-ping-yee-iso-latin-1%c2%a0font-in-linux-kernel/"
		einfo "logo - CONFIG_LOGO_LARRY_CLUT224 http://www.gentoo.org/proj/en/desktop/artwork/artwork.xml"
	fi
	if use backports; then
		einfo "backports enable compat-wireless patches http://www.orbit-lab.org/kernel"
	fi
	if use hardened; then
		einfo "hardened enable http://grsecurity.net patches"
	fi
}
