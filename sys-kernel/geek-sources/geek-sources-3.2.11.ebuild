# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
K_NOUSENAME="yes"
K_NOSETEXTRAVERSION="yes"
K_SECURITY_UNSUPPORTED="1"
K_DEBLOB_AVAILABLE="1"
ETYPE="sources"

CKV="${PVR/-r/-git}"
# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"
#CKV="3.2.1"

inherit kernel-2
detect_version

grsecurity_version="201203162123"
grsecurity_src="http://grsecurity.net/test/grsecurity-2.9-${PV}-${grsecurity_version}.patch"
grsecurity_url="http://grsecurity.net"
compat_wireless_version="3.3-rc1-2"
compat_wireless_src="http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.3/compat-wireless-${compat_wireless_version}.tar.bz2"
compat_wireless_url="http://wireless.kernel.org/en/users/Download/stable"
css_version="1.8.3-20120301"
css_src="http://sourceforge.jp/frs/redir.php?m=jaist&f=/tomoyo/49684/ccs-patch-${css_version}.tar.gz"
css_url="http://tomoyo.sourceforge.jp"
ck_version="3.2"
ck_src="http://ck.kolivas.org/patches/3.0/3.2/3.2-ck1/patch-${ck_version}-ck1.bz2"
ck_url="http://ck-hack.blogspot.com"
fbcondecor_src="http://sources.gentoo.org/cgi-bin/viewvc.cgi/linux-patches/genpatches-2.6/trunk/3.2/4200_fbcondecor-0.9.6.patch"
fbcondecor_url="http://dev.gentoo.org/~spock/projects/fbcondecor"
rt_version="3.2.11-rt20"
rt_src="http://www.kernel.org/pub/linux/kernel/projects/rt/3.2/patch-${rt_version}.patch.xz"
rt_url="http://www.kernel.org/pub/linux/kernel/projects/rt"

KEYWORDS="~amd64 ~x86"
RDEPEND=">=sys-devel/gcc-4.5 \
	backports?	( !net-wireless/athload )
	grsecurity?	( >=sys-apps/gradm-2.2.2 )
	rt?		( x11-drivers/nvidia-drivers[rt(+)] )
	tomoyo?		( sys-apps/ccs-tools )"

IUSE="backports branding ck deblob fbcondecor grsecurity rt tomoyo"
DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, rt, tomoyo, and other patches"
HOMEPAGE="http://www.kernel.org http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary ${compat_wireless_url} ${grsecurity_url} ${css_url} ${ck_url} ${fbcondecor_url} ${rt_url}"
SRC_URI="${KERNEL_URI} ${ARCH_URI}
	backports?	( ${compat_wireless_src} )
	ck?		( ${ck_src} )
	fbcondecor?	( ${fbcondecor_src} )
	grsecurity?	( ${grsecurity_src} )
	rt?		( ${rt_src} )
	tomoyo?		( ${css_src} )"

REQUIRED_USE="grsecurity? ( !tomoyo ) tomoyo? ( !grsecurity )
	ck? ( !grsecurity ) ck? ( !tomoyo )
	fbcondecor? ( !grsecurity ) fbcondecor? ( !tomoyo )
	rt? ( !grsecurity ) rt? ( !tomoyo )"

KV_FULL="${PVR}-geek"
EXTRAVERSION="${RELEASE}-geek"
SLOT="${PV}"
S="${WORKDIR}/linux-${KV_FULL}"

src_unpack() {

	kernel-2_src_unpack
	cd "${S}"

	einfo "Make kernel default configs"
	cp ${FILESDIR}/${PVR}/config-* . || die "cannot copy kernel config";
	cp ${FILESDIR}/${PVR}/merge.pl ${FILESDIR}/${PVR}/Makefile.config . &>/dev/null || die "cannot copy kernel files";
	make -f Makefile.config VERSION=${PVR} configs &>/dev/null || die "cannot generate kernel .config files from config-* files"

	use grsecurity && epatch ${DISTDIR}/grsecurity-2.9-${PV}-${grsecurity_version}.patch
	if use tomoyo; then
		cd ${T}
		unpack "ccs-patch-${css_version}.tar.gz"
		cp "${T}/patches/ccs-patch-3.2.diff" "${S}/ccs-patch-3.2.diff"
		cd "${S}"
		EPATCH_OPTS="-p1" epatch "${S}/ccs-patch-3.2.diff"
		rm -f "${S}/ccs-patch-3.2.diff"
		rm -rf ${T}/* # Clean temp
	fi

	if use ck; then
		EPATCH_OPTS="-p1 -F1 -s" \
		epatch ${DISTDIR}/patch-${ck_version}-ck1.bz2
		EPATCH_OPTS="-p1 -F1 -s" \
		epatch ${FILESDIR}/0001-block-prepare-I-O-context-code-for-BFQ-v3r2-for-3.2.patch
		EPATCH_OPTS="-p1 -F1 -s" \
		epatch ${FILESDIR}/0002-block-cgroups-kconfig-build-bits-for-BFQ-v3r2-3.2.patch
		EPATCH_OPTS="-p1 -F1 -s" \
		epatch ${FILESDIR}/0003-block-introduce-the-BFQ-v3r2-I-O-sched-for-3.2.patch
	fi

	if use fbcondecor; then
		epatch ${DISTDIR}/4200_fbcondecor-0.9.6.patch
	fi

	if use rt; then
		epatch "${DISTDIR}/patch-${rt_version}.patch.xz"
	fi

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
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/linux-2.6-32bit-mmap-exec-randomization.patch
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/linux-2.6-i386-nx-emulation.patch

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
	epatch "${FILESDIR}"/"${PVR}"/NFSv4-Reduce-the-footprint-of-the-idmapper.patch
	epatch "${FILESDIR}"/"${PVR}"/NFSv4-Further-reduce-the-footprint-of-the-idmapper.patch

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
	use backports && epatch "${FILESDIR}"/"${PVR}"/modpost-add-option-to-allow-external-modules-to-avoi.patch

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

# rhbz#605888
	epatch "${FILESDIR}"/"${PVR}"/dmar-disable-when-ricoh-multifunction.patch

	epatch "${FILESDIR}"/"${PVR}"/revert-efi-rtclock.patch
	epatch "${FILESDIR}"/"${PVR}"/efi-dont-map-boot-services-on-32bit.patch

	epatch "${FILESDIR}"/"${PVR}"/hibernate-freeze-filesystems.patch

	epatch "${FILESDIR}"/"${PVR}"/lis3-improve-handling-of-null-rate.patch

# utrace.
#	EPATCH_OPTS="-p1 -F1 -s" \
#	epatch "${FILESDIR}"/"${PVR}"/utrace.patch # Failed

#rhbz 752176
	epatch "${FILESDIR}"/"${PVR}"/sysfs-msi-irq-per-device.patch

# rhbz 754907
	epatch "${FILESDIR}"/"${PVR}"/hpsa-add-irqf-shared.patch

#	epatch "${FILESDIR}"/"${PVR}"/pci-crs-blacklist.patch

#rhbz 717735
#	EPATCH_OPTS="-p1 -F1 -s" \
#	epatch "${FILESDIR}"/"${PVR}"/nfs-client-freezer.patch # Failed

#rhbz 590880
#	EPATCH_OPTS="-p1 -F1 -s" \
#	epatch "${FILESDIR}"/"${PVR}"/alps.patch # Failed
	epatch "${FILESDIR}"/2600_Input-ALPS-synaptics-touchpad.patch

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
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/procfs-parse-mount-options.patch
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/procfs-add-hidepid-and-gid-mount-options.patch
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/proc-fix-null-pointer-deref-in-proc_pid_permission.patch

#rhbz 772772
	epatch "${FILESDIR}"/"${PVR}"/rt2x00_fix_MCU_request_failures.patch

#rhbz 788269
	epatch "${FILESDIR}"/"${PVR}"/jbd2-clear-BH_Delay-and-BH_Unwritten-in-journal_unmap_buf.patch

#rhbz 785806
	epatch "${FILESDIR}"/"${PVR}"/e1000e-Avoid-wrong-check-on-TX-hang.patch

#rhbz 754518
#	epatch "${FILESDIR}"/"${PVR}"/scsi-sd_revalidate_disk-prevent-NULL-ptr-deref.patch
	epatch "${FILESDIR}"/"${PVR}"/scsi-fix-sd_revalidate_disk-oops.patch

#rhbz 727865 730007
	epatch "${FILESDIR}"/"${PVR}"/ACPICA-Fix-regression-in-FADT-revision-checks.patch

#rhbz 728478
	epatch "${FILESDIR}"/"${PVR}"/sony-laptop-Enable-keyboard-backlight-by-default.patch

	epatch "${FILESDIR}"/"${PVR}"/unhandled-irqs-switch-to-polling.patch

	epatch "${FILESDIR}"/"${PVR}"/weird-root-dentry-name-debug.patch

	epatch "${FILESDIR}"/"${PVR}"/x86-ioapic-add-register-checks-for-bogus-io-apic-entries.patch

#rhbz 803809 CVE-2012-1179
	epatch "${FILESDIR}"/"${PVR}"/mm-thp-fix-pmd_bad-triggering.patch

# END OF PATCH APPLICATIONS

	if use backports; then
		echo
		einfo "Apply compat-wireless patches"
		echo
		unpack compat-wireless-${compat_wireless_version}.tar.bz2
		cd compat-wireless-${compat_wireless_version}

		epatch "${FILESDIR}"/"${PVR}"/compat-wireless-config-fixups.patch
		epatch "${FILESDIR}"/"${PVR}"/compat-wireless-pr_fmt-warning-avoidance.patch
		epatch "${FILESDIR}"/"${PVR}"/compat-wireless-integrated-build.patch

		epatch "${FILESDIR}"/"${PVR}"/compat-wireless-rtl8192cu-Fix-WARNING-on-suspend-resume.patch

	# Pending upstream fixes
		epatch "${FILESDIR}"/"${PVR}"/mac80211-fix-debugfs-key-station-symlink.patch
		epatch "${FILESDIR}"/"${PVR}"/brcmsmac-fix-tx-queue-flush-infinite-loop.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-Use-the-right-headroom-size-for-mesh-mgmt-f.patch
		epatch "${FILESDIR}"/"${PVR}"/b43-add-option-to-avoid-duplicating-device-support-w.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-update-oper_channel-on-ibss-join.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-set-bss_conf.idle-when-vif-is-connected.patch
		epatch "${FILESDIR}"/"${PVR}"/iwlwifi-fix-PCI-E-transport-inta-race.patch
		epatch "${FILESDIR}"/"${PVR}"/bcma-Fix-mem-leak-in-bcma_bus_scan.patch
		epatch "${FILESDIR}"/"${PVR}"/rt2800lib-fix-wrong-128dBm-when-signal-is-stronger-t.patch
		epatch "${FILESDIR}"/"${PVR}"/iwlwifi-make-Tx-aggregation-enabled-on-ra-be-at-DEBU.patch
		epatch "${FILESDIR}"/"${PVR}"/ssb-fix-cardbus-slot-in-hostmode.patch
		epatch "${FILESDIR}"/"${PVR}"/iwlwifi-don-t-mess-up-QoS-counters-with-non-QoS-fram.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-timeout-a-single-frame-in-the-rx-reorder-bu.patch
		epatch "${FILESDIR}"/"${PVR}"/ath9k-use-WARN_ON_ONCE-in-ath_rc_get_highest_rix.patch
		epatch "${FILESDIR}"/"${PVR}"/mwifiex-handle-association-failure-case-correctly.patch
		epatch "${FILESDIR}"/"${PVR}"/ath9k-Fix-kernel-panic-during-driver-initilization.patch
		epatch "${FILESDIR}"/"${PVR}"/mwifiex-add-NULL-checks-in-driver-unload-path.patch
		epatch "${FILESDIR}"/"${PVR}"/ath9k-fix-a-WEP-crypto-related-regression.patch
		epatch "${FILESDIR}"/"${PVR}"/ath9k_hw-fix-a-RTS-CTS-timeout-regression.patch
		epatch "${FILESDIR}"/"${PVR}"/bcma-don-t-fail-for-bad-SPROM-CRC.patch
		epatch "${FILESDIR}"/"${PVR}"/zd1211rw-firmware-needs-duration_id-set-to-zero-for-.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-Fix-a-rwlock-bad-magic-bug.patch
		epatch "${FILESDIR}"/"${PVR}"/rtlwifi-Modify-rtl_pci_init-to-return-0-on-success.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-call-rate-control-only-after-init.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-do-not-call-rate-control-.tx_status-before-.patch
		epatch "${FILESDIR}"/"${PVR}"/mwifiex-clear-previous-security-setting-during-assoc.patch
		epatch "${FILESDIR}"/"${PVR}"/ath9k-stop-on-rates-with-idx-1-in-ath9k-rate-control.patch
		epatch "${FILESDIR}"/"${PVR}"/ath9k_hw-prevent-writes-to-const-data-on-AR9160.patch
		epatch "${FILESDIR}"/"${PVR}"/rt2x00-fix-a-possible-NULL-pointer-dereference.patch
		epatch "${FILESDIR}"/"${PVR}"/iwlwifi-fix-key-removal.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-zero-initialize-count-field-in-ieee80211_tx.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-Fix-a-warning-on-changing-to-monitor-mode-f.patch
		epatch "${FILESDIR}"/"${PVR}"/brcm80211-smac-fix-endless-retry-of-A-MPDU-transmiss.patch
		epatch "${FILESDIR}"/"${PVR}"/brcm80211-smac-only-print-block-ack-timeout-message-.patch

		epatch "${FILESDIR}"/"${PVR}"/rt2x00_fix_MCU_request_failures.patch

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
	nonfatal dodoc "${FILESDIR}/${PVR}"/{README.txt,TODO,*notes.txt}

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
	use backports && einfo "backports enable compat-wireless patches ${compat_wireless_url}"
	use ck && einfo "ck enable ${ck_url} patches"
	use fbcondecor && einfo "fbcondecor enable ${fbcondecor_url} patches"
	use grsecurity && einfo "grsecurity enable ${grsecurity_url} patches"
	use rt && einfo "rt enable ${rt_url} patches"
	use tomoyo && einfo "tomoyo enable ${css_url} patches"
}
