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
#CKV="3.3"

inherit kernel-2
detect_version

grsecurity_version="201204172135"
grsecurity_src="http://grsecurity.net/test/grsecurity-2.9-${PV}-${grsecurity_version}.patch"
grsecurity_url="http://grsecurity.net"
css_version="1.8.3-20120401"
css_src="http://sourceforge.jp/frs/redir.php?m=jaist&f=/tomoyo/49684/ccs-patch-${css_version}.tar.gz"
css_url="http://tomoyo.sourceforge.jp"
ck_version="3.3"
ck_src="http://ck.kolivas.org/patches/3.0/3.3/3.3-ck1/patch-${ck_version}-ck1.bz2"
ck_url="http://ck-hack.blogspot.com"
fbcondecor_src="http://sources.gentoo.org/cgi-bin/viewvc.cgi/linux-patches/genpatches-2.6/trunk/3.3/4200_fbcondecor-0.9.6.patch"
fbcondecor_url="http://dev.gentoo.org/~spock/projects/fbcondecor"
bld_version="3.3-rc3"
bld_src="http://bld.googlecode.com/files/bld-${bld_version}.tar.bz2"
bld_url="http://code.google.com/p/bld"

KEYWORDS="~amd64 ~x86"
RDEPEND=">=sys-devel/gcc-4.5 \
	grsecurity?	( >=sys-apps/gradm-2.2.2 )
	tomoyo?		( sys-apps/ccs-tools )"

IUSE="bld branding ck deblob fbcondecor grsecurity tomoyo"
DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, tomoyo and other patches"
HOMEPAGE="http://www.kernel.org http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary ${bld_url} ${grsecurity_url} ${css_url} ${ck_url} ${fbcondecor_url}"
SRC_URI="${KERNEL_URI} ${ARCH_URI}
	ck?		( ${ck_src} )
	fbcondecor?	( ${fbcondecor_src} )
	grsecurity?	( ${grsecurity_src} )
	tomoyo?		( ${css_src} )
	bld?		( ${bld_src} )"

REQUIRED_USE="grsecurity? ( !tomoyo ) tomoyo? ( !grsecurity )
	ck? ( !grsecurity ) ck? ( !tomoyo )
	fbcondecor? ( !grsecurity ) fbcondecor? ( !tomoyo )
	bld? ( !grsecurity ) bld? ( !tomoyo ) bld? ( !ck )"

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
		cp "${T}/patches/ccs-patch-3.3.diff" "${S}/ccs-patch-3.3.diff"
		cd "${S}"
		EPATCH_OPTS="-p1" epatch "${S}/ccs-patch-3.3.diff"
		rm -f "${S}/ccs-patch-3.3.diff"
		# Clean temp
		rm -rf "${T}/config.ccs" "${T}/COPYING.ccs" "${T}/README.ccs"
		rm -r "${T}/include" "${T}/patches" "${T}/security" "${T}/specs"
	fi

	if use ck; then
		EPATCH_OPTS="-p1 -F1 -s" \
		epatch ${DISTDIR}/patch-${ck_version}-ck1.bz2
	fi

	if use fbcondecor; then
		epatch ${DISTDIR}/4200_fbcondecor-0.9.6.patch
	fi

	if use bld; then
		cd ${T}
		unpack "bld-${bld_version}.tar.bz2"
		cp "${T}/bld-${bld_version}/BLD_${bld_version}-feb12.patch" "${S}/BLD_${bld_version}-feb12.patch"
		cd "${S}"
		EPATCH_OPTS="-p1" epatch "${S}/BLD_${bld_version}-feb12.patch"
		rm -f "${S}/BLD_${bld_version}-feb12.patch"
		rm -r "${T}/bld-${bld_version}" # Clean temp
	fi

### BRANCH APPLY ###

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-makefile-after_link.patch

# Architecture patches
# x86(-64)

#
# ARM
#
# 	epatch "${FILESDIR}"/"${PVR}"/arm-omap-dt-compat.patch
	epatch "${FILESDIR}"/"${PVR}"/arm-smsc-support-reading-mac-address-from-device-tree.patch

	epatch "${FILESDIR}"/"${PVR}"/taint-vbox.patch
#
# NX Emulation
#
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/linux-2.6-32bit-mmap-exec-randomization.patch
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/linux-2.6-i386-nx-emulation.patch
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/nx-emu-remove-cpuinitdata-for-disable_nx-on-x86_32.patch

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
	epatch "${FILESDIR}"/"${PVR}"/NFSv4-Minor-cleanups-for-nfs4_handle_exception-and-n.patch

# USB

# WMI

# ACPI
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-acpi-video.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-acpi-video-dos.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-acpi-debug-infinite-loop.patch
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

#rhbz 808559
	epatch "${FILESDIR}"/"${PVR}"/ALSA-hda-realtek-Add-quirk-for-Mac-Pro-5-1-machines.patch

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

	epatch "${FILESDIR}"/"${PVR}"/silence-timekeeping-spew.patch

# Make fbcon not show the penguins with 'quiet'
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-fbcon-logo.patch

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
	epatch "${FILESDIR}"/"${PVR}"/drm-i915-dp-stfu.patch
	epatch "${FILESDIR}"/"${PVR}"/drm-i915-fbc-stfu.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-intel-iommu-igfx.patch

# silence the ACPI blacklist code
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-acpi-blacklist.patch
	epatch "${FILESDIR}"/"${PVR}"/quite-apm.patch

# Media (V4L/DVB/IR) updates/fixes/experimental drivers
#  apply if non-empty
	epatch "${FILESDIR}"/"${PVR}"/add-poll-requested-events.patch
	epatch "${FILESDIR}"/"${PVR}"/dvb_frontend_switch_regression_fix.patch

# Patches headed upstream

	epatch "${FILESDIR}"/"${PVR}"/disable-i8042-check-on-apple-mac.patch

# rhbz#605888
	epatch "${FILESDIR}"/"${PVR}"/dmar-disable-when-ricoh-multifunction.patch

	epatch "${FILESDIR}"/"${PVR}"/efi-dont-map-boot-services-on-32bit.patch

# FIXME
#	epatch "${FILESDIR}"/"${PVR}"/hibernate-freeze-filesystems.patch
	epatch "${FILESDIR}"/"${PVR}"/hibernate-watermark.patch

	epatch "${FILESDIR}"/"${PVR}"/lis3-improve-handling-of-null-rate.patch

	epatch "${FILESDIR}"/"${PVR}"/bluetooth-use-after-free.patch
	epatch "${FILESDIR}"/"${PVR}"/Bluetooth-Adding-USB-device-13d3-3375-as-an-Atheros-.patch

	epatch "${FILESDIR}"/"${PVR}"/ips-noirq.patch

# utrace.
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/utrace.patch

#	epatch "${FILESDIR}"/"${PVR}"/pci-crs-blacklist.patch

	epatch "${FILESDIR}"/"${PVR}"/ext4-Support-check-none-nocheck-mount-options.patch

#rhbz 772772
	epatch "${FILESDIR}"/"${PVR}"/rt2x00_fix_MCU_request_failures.patch

#rhbz 754518
#	epatch "${FILESDIR}"/"${PVR}"/scsi-sd_revalidate_disk-prevent-NULL-ptr-deref.patch

#rhbz 789644
	epatch "${FILESDIR}"/"${PVR}"/mcelog-rcu-splat.patch

#rhbz 728478
	epatch "${FILESDIR}"/"${PVR}"/sony-laptop-Enable-keyboard-backlight-by-default.patch

#rhbz 804957 CVE-2012-1568
	use grsecurity || epatch "${FILESDIR}"/"${PVR}"/shlib_base_randomize.patch

	epatch "${FILESDIR}"/"${PVR}"/unhandled-irqs-switch-to-polling.patch

# debug patches
	epatch "${FILESDIR}"/"${PVR}"/weird-root-dentry-name-debug.patch
	epatch "${FILESDIR}"/"${PVR}"/debug-808990.patch

#rhbz 804347
	epatch "${FILESDIR}"/"${PVR}"/x86-add-io_apic_ops-to-allow-interception.patch
	epatch "${FILESDIR}"/"${PVR}"/x86-apic_ops-Replace-apic_ops-with-x86_apic_ops.patch
	epatch "${FILESDIR}"/"${PVR}"/xen-x86-Implement-x86_apic_ops.patch

#rhbz 770476
	epatch "${FILESDIR}"/"${PVR}"/iwlwifi-do-not-nulify-ctx-vif-on-reset.patch

#rhbz 808207 CVE-2012-1601
	epatch "${FILESDIR}"/"${PVR}"/KVM-Ensure-all-vcpus-are-consistent-with-in-kernel-i.patch

#rhbz 808603
	epatch "${FILESDIR}"/"${PVR}"/wimax-i2400m-prevent-a-possible-kernel-bug-due-to-mi.patch

#rhbz 807632
	epatch "${FILESDIR}"/"${PVR}"/libata-forbid-port-runtime-pm-by-default.patch

#rhbz 809014
	epatch "${FILESDIR}"/"${PVR}"/x86-Use-correct-byte-sized-register-constraint-in-__xchg_op.patch
	epatch "${FILESDIR}"/"${PVR}"/x86-Use-correct-byte-sized-register-constraint-in-__add.patch

#rhbz 797559
	epatch "${FILESDIR}"/"${PVR}"/x86-microcode-Fix-sysfs-warning-during-module-unload-on-unsupported-CPUs.patch
	epatch "${FILESDIR}"/"${PVR}"/x86-microcode-Ensure-that-module-is-only-loaded-for-supported-AMD-CPUs.patch

#rhbz 806295
	epatch "${FILESDIR}"/"${PVR}"/disable-hid-battery.patch

#rhbz 814149 814155 CVE-2012-2121
	epatch "${FILESDIR}"/"${PVR}"/KVM-unmap-pages-from-the-iommu-when-slots-are-removed.patch

#rhbz 814278 814289 CVE-2012-2119
	epatch "${FILESDIR}"/"${PVR}"/macvtap-zerocopy-validate-vector-length.patch

#rhbz 814523 806722 CVE-2012-2123
	epatch "${FILESDIR}"/"${PVR}"/fcaps-clear-the-same-personality-flags-as-suid-when-.patch
	epatch "${FILESDIR}"/"${PVR}"/security-fix-compile-error-in-commoncap.c.patch

### END OF PATCH APPLICATIONS ###

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

	if [ ! -e ${ROOT}usr/src/linux ]
	then
		ln -sf linux-${P} ${ROOT}usr/src/linux
	fi

	einfo "Now is the time to configure and build the kernel."
	if use branding; then
		einfo "branding enable"
		einfo "font - CONFIG_FONT_ISO_LATIN_1_8x16 http://sudormrf.wordpress.com/2010/10/23/ka-ping-yee-iso-latin-1%c2%a0font-in-linux-kernel/"
		einfo "logo - CONFIG_LOGO_LARRY_CLUT224 http://www.gentoo.org/proj/en/desktop/artwork/artwork.xml"
	fi
	use ck && einfo "ck enable ${ck_url} patches"
	use fbcondecor && einfo "fbcondecor enable ${fbcondecor_url} patches"
	use grsecurity && einfo "grsecurity enable ${grsecurity_url} patches"
	use tomoyo && einfo "tomoyo enable ${css_url} patches"
	use bld && einfo "bld enable ${bld_url} patches"
}
