# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
K_NOUSENAME="yes"
K_NOSETEXTRAVERSION="yes"
K_SECURITY_UNSUPPORTED="1"
K_DEBLOB_AVAILABLE="0"
ETYPE="sources"

#CKV="${PVR/-r/-git}"
# only use this if it's not an _rc/_pre release
#[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"
CKV="3.4-rc4"

inherit kernel-2
detect_version

#grsecurity_version="201204062021"
#grsecurity_src="http://grsecurity.net/test/grsecurity-2.9-${PV}-${grsecurity_version}.patch"
#grsecurity_url="http://grsecurity.net"
#css_version="1.8.3-20120301"
#css_src="http://sourceforge.jp/frs/redir.php?m=jaist&f=/tomoyo/49684/ccs-patch-${css_version}.tar.gz"
#css_url="http://tomoyo.sourceforge.jp"
#ck_version="3.3"
#ck_src="http://ck.kolivas.org/patches/3.0/3.3/3.3-ck1/patch-${ck_version}-ck1.bz2"
#ck_url="http://ck-hack.blogspot.com"
fbcondecor_src="http://sources.gentoo.org/cgi-bin/viewvc.cgi/linux-patches/genpatches-2.6/trunk/3.4/4200_fbcondecor-0.9.6.patch"
fbcondecor_url="http://dev.gentoo.org/~spock/projects/fbcondecor"
#bld_version="3.3-rc3"
#bld_src="http://bld.googlecode.com/files/bld-${bld_version}.tar.bz2"
#bld_url="http://code.google.com/p/bld"
rt_version="3.4-rc3-rt5"
rt_src="http://www.kernel.org/pub/linux/kernel/projects/rt/3.4/patch-${rt_version}.patch.xz"
rt_url="http://www.kernel.org/pub/linux/kernel/projects/rt"

KEYWORDS=""
#KEYWORDS="~amd64 ~x86"

#	grsecurity?	( >=sys-apps/gradm-2.2.2 )
#	tomoyo?		( sys-apps/ccs-tools )
RDEPEND=">=sys-devel/gcc-4.5"

IUSE="branding deblob fbcondecor rt"
#IUSE="bld branding ck deblob fbcondecor grsecurity tomoyo"
DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, tomoyo and other patches"

HOMEPAGE="http://www.kernel.org http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary ${fbcondecor_url} ${rt_url}"
#HOMEPAGE="http://www.kernel.org http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary ${bld_url} ${grsecurity_url} ${css_url} ${ck_url} ${fbcondecor_url}"
#	ck?		( ${ck_src} )
#	fbcondecor?	( ${fbcondecor_src} )
#	grsecurity?	( ${grsecurity_src} )
#	tomoyo?		( ${css_src} )
#	bld?		( ${bld_src} )
SRC_URI="${KERNEL_URI} ${ARCH_URI}
	rt?		( ${rt_src} )"

#REQUIRED_USE=grsecurity? ( !tomoyo ) tomoyo? ( !grsecurity )
#	ck? ( !grsecurity ) ck? ( !tomoyo )
#	fbcondecor? ( !grsecurity ) fbcondecor? ( !tomoyo )
#	bld? ( !grsecurity ) bld? ( !tomoyo ) bld? ( !ck )"

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

#	use grsecurity && epatch ${DISTDIR}/grsecurity-2.9-${PV}-${grsecurity_version}.patch

#	if use tomoyo; then
#		cd ${T}
#		unpack "ccs-patch-${css_version}.tar.gz"
#		cp "${T}/patches/ccs-patch-3.3.diff" "${S}/ccs-patch-3.3.diff"
#		cd "${S}"
#		EPATCH_OPTS="-p1" epatch "${S}/ccs-patch-3.3.diff"
#		rm -f "${S}/ccs-patch-3.3.diff"
		# Clean temp
#		rm -rf "${T}/config.ccs" "${T}/COPYING.ccs" "${T}/README.ccs"
#		rm -r "${T}/include" "${T}/patches" "${T}/security" "${T}/specs"
#	fi

#	if use ck; then
#		EPATCH_OPTS="-p1 -F1 -s" \
#		epatch ${DISTDIR}/patch-${ck_version}-ck1.bz2
#	fi

	if use fbcondecor; then
		epatch ${DISTDIR}/4200_fbcondecor-0.9.6.patch
	fi

#	if use bld; then
#		cd ${T}
#		unpack "bld-${bld_version}.tar.bz2"
#		cp "${T}/bld-${bld_version}/BLD_${bld_version}-feb12.patch" "${S}/BLD_${bld_version}-feb12.patch"
#		cd "${S}"
#		EPATCH_OPTS="-p1" epatch "${S}/BLD_${bld_version}-feb12.patch"
#		rm -f "${S}/BLD_${bld_version}-feb12.patch"
#		rm -r "${T}/bld-${bld_version}" # Clean temp
#	fi

	if use rt; then
		epatch "${DISTDIR}/patch-${rt_version}.patch.xz"
	fi

### BRANCH APPLY ###

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-makefile-after_link.patch

	epatch "${FILESDIR}"/"${PVR}"/taint-vbox.patch

# Architecture patches
# x86(-64)
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-32bit-mmap-exec-randomization.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-i386-nx-emulation.patch
	epatch "${FILESDIR}"/"${PVR}"/nx-emu-remove-cpuinitdata-for-disable_nx-on-x86_32.patch

#
# ARM
#
#	epatch "${FILESDIR}"/"${PVR}"/arm-omap-dt-compat.patch
#	epatch "${FILESDIR}"/"${PVR}"/arm-smsc-support-reading-mac-address-from-device-tree.patch
	epatch "${FILESDIR}"/"${PVR}"/arm-tegra-nvec-kconfig.patch

#
# bugfixes to drivers and filesystems
#

# ext4

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
	epatch "${FILESDIR}"/"${PVR}"/acpi-sony-nonvs-blacklist.patch

#
# PCI
#

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

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6.30-no-pcspkr-modalias.patch

# Allow to use 480600 baud on 16C950 UARTs
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-serial-460800.patch

# Silence some useless messages that still get printed with 'quiet'
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-noise.patch

# Make fbcon not show the penguins with 'quiet'
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-fbcon-logo.patch

# Changes to upstream defaults.


# /dev/crash driver.
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-crash-driver.patch

# Hack e1000e to work on Montevina SDV
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-e1000-ich9-montevina.patch

# crypto/
	epatch "${FILESDIR}"/"${PVR}"/modsign-20111207.patch

# Assorted Virt Fixes
	epatch "${FILESDIR}"/"${PVR}"/fix_xen_guest_on_old_EC2.patch

# DRM core
#	epatch "${FILESDIR}"/"${PVR}"/drm-edid-try-harder-to-fix-up-broken-headers.patch
	epatch "${FILESDIR}"/"${PVR}"/drm-vgem.patch

# Nouveau DRM

# Intel DRM
	epatch "${FILESDIR}"/"${PVR}"/drm-i915-dp-stfu.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-intel-iommu-igfx.patch

# silence the ACPI blacklist code
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-acpi-blacklist.patch
	epatch "${FILESDIR}"/"${PVR}"/quite-apm.patch

# Patches headed upstream
	epatch "${FILESDIR}"/"${PVR}"/disable-i8042-check-on-apple-mac.patch

# rhbz#605888
	epatch "${FILESDIR}"/"${PVR}"/dmar-disable-when-ricoh-multifunction.patch

	epatch "${FILESDIR}"/"${PVR}"/efi-dont-map-boot-services-on-32bit.patch

# FIXME: REBASE
#	epatch "${FILESDIR}"/"${PVR}"/hibernate-freeze-filesystems.patch
	epatch "${FILESDIR}"/"${PVR}"/hibernate-watermark.patch

	epatch "${FILESDIR}"/"${PVR}"/lis3-improve-handling-of-null-rate.patch

	epatch "${FILESDIR}"/"${PVR}"/power-x86-destdir.patch

	epatch "${FILESDIR}"/"${PVR}"/hfsplus-Fix-bless-ioctl-when-used-with-hardlinks.patch

#rhbz 754518
	epatch "${FILESDIR}"/"${PVR}"/scsi-sd_revalidate_disk-prevent-NULL-ptr-deref.patch

#rhbz 804957 CVE-2012-1568
	epatch "${FILESDIR}"/"${PVR}"/shlib_base_randomize.patch

	epatch "${FILESDIR}"/"${PVR}"/unhandled-irqs-switch-to-polling.patch

	epatch "${FILESDIR}"/"${PVR}"/weird-root-dentry-name-debug.patch

#selinux ptrace child permissions
	epatch "${FILESDIR}"/"${PVR}"/selinux-apply-different-permission-to-ptrace-child.patch

#Highbank clock functions
	epatch "${FILESDIR}"/"${PVR}"/highbank-export-clock-functions.patch 

#vgaarb patches.  blame mjg59
	epatch "${FILESDIR}"/"${PVR}"/vgaarb-vga_default_device.patch

#rhbz 797559
	epatch "${FILESDIR}"/"${PVR}"/x86-microcode-Fix-sysfs-warning-during-module-unload-on-unsupported-CPUs.patch
	epatch "${FILESDIR}"/"${PVR}"/x86-microcode-Ensure-that-module-is-only-loaded-for-supported-AMD-CPUs.patch

#rhbz 814278 814289 CVE-2012-2119
	epatch "${FILESDIR}"/"${PVR}"/macvtap-zerocopy-validate-vector-length.patch

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
		ln -s linux-${P} ${ROOT}usr/src/linux
	fi

	einfo "Now is the time to configure and build the kernel."
	if use branding; then
		einfo "branding enable"
		einfo "font - CONFIG_FONT_ISO_LATIN_1_8x16 http://sudormrf.wordpress.com/2010/10/23/ka-ping-yee-iso-latin-1%c2%a0font-in-linux-kernel/"
		einfo "logo - CONFIG_LOGO_LARRY_CLUT224 http://www.gentoo.org/proj/en/desktop/artwork/artwork.xml"
	fi
#	use backports && einfo "backports enable compat-wireless patches ${compat_wireless_url}"
	use ck && einfo "ck enable ${ck_url} patches"
	use fbcondecor && einfo "fbcondecor enable ${fbcondecor_url} patches"
	use grsecurity && einfo "grsecurity enable ${grsecurity_url} patches"
	use tomoyo && einfo "tomoyo enable ${css_url} patches"
	use bld && einfo "bld enable ${bld_url} patches"
	use rt && einfo "rt enable ${rt_url} patches"
}
