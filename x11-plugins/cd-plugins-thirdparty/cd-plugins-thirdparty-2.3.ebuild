# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
PYTHON_DEPEND="2"
#SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit multilib python

DESCRIPTION="Third-party plugins for cairo-dock"
HOMEPAGE="http://www.glx-dock.org/mc_album.php?a=6"
SRC_URI_BASE="http://download.tuxfamily.org/glxdock/mediacolor/album6"
SRC_URI="pidgin? (
		${SRC_URI_BASE}/1297178000_be5288d94a/Pidgin.tar.gz -> Pidgin-${PV}.tar.gz
		http://home.arcor.de/dpolke/distfiles/Pidgin-Purple-theme.tar.bz2 )
	xchat? ( ${SRC_URI_BASE}/1297178001_cdbccd3f19/Xchat.tar.gz -> Xchat-${PV}.tar.gz )"

LICENSE="|| ( GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pidgin xchat"
#REQUIRED_USE="|| ( ${IUSE} )"

RDEPEND="=x11-plugins/cd-plugins-core-${PV}*[python]"
DEPEND=""

S="${WORKDIR}"

pkg_setup() {
	# !!! right now REQUIRED_USE cannot be used because !!!
	# !!! python eclass does not support EAPI="4" yet   !!!
	# BEGIN
	local plugin count=0
	for plugin in ${IUSE}; do
		use ${plugin} && $(( count++ )) 2>/dev/null
	done
	[ ${count} -eq 0 ] && \
		die "No plugin selected for installation! Abort"
	# END
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	python_convert_shebangs -r 2 .
	# fix preview link
	if use pidgin; then
		mv Pidgin/themes/Eve-Wall-E/preview{@,} || die
	fi
}

my_installplugin() {
	if use $1; then
		local CD_THIRDPARTY_DIR="/usr/$(get_libdir)/cairo-dock/third-party"
		dodir "${CD_THIRDPARTY_DIR}"

		sed -e "/^from /s/\(CDApplet\)/cairodock.\1/" \
			-e "/CDApplet$/s/$/ as CDApplet/" \
			-i $2/$2 || die
		cp -R $2 "${ED}/${CD_THIRDPARTY_DIR}/" || die
	fi
}

src_install() {
	my_installplugin pidgin Pidgin
	my_installplugin xchat Xchat
}

pkg_postinst() {
	elog "These plugins can be made available by creating a symlink from"
	elog "'${ROOT}usr/$(get_libdir)/cairo-dock/third-party' to"
	elog "'\${HOME}/.config/cairo-dock/third-party'"
}
