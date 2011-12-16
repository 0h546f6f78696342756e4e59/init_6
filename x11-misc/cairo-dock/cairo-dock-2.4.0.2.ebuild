# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit cmake-utils eutils cairo-dock

DESCRIPTION="Cairo-dock is a fast, responsive, Mac OS X-like dock."
HOMEPAGE="http://www.glx-dock.org"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="crypt xcomposite"

RDEPEND="
	dev-libs/dbus-glib
	dev-libs/glib:2
	dev-libs/libxml2:2
	gnome-base/librsvg:2
	net-misc/curl
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:2
	x11-libs/gtkglext
	x11-libs/libXrender
	crypt? ( sys-libs/glibc )
	xcomposite? (
		x11-libs/libXcomposite
		x11-libs/libXinerama
		x11-libs/libXtst
	)"

DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig
	sys-devel/gettext"

src_prepare() {
	cairo-dock_src_prepare
}

src_configure() {
	# glitz support has been dropped from recent cairo, so drop it here as well.
	mycmakeargs+=( "-DENABLE_GLITZ=OFF" )
	cmake-utils_src_configure
}

pkg_postinst() {
	elog "Additional plugins are available to extend the functionality"
	elog "of Cairo-Dock. It is recommended to install at least"
	elog "x11-misc/cairo-dock-plugins-core."
	elog
	elog "Cairo-Dock is an app that draws on a RGBA GLX visual."
	elog "Some users have noticed that if the dock is launched,"
	elog "severals qt4-based applications could crash, like skype or vlc."
	elog "If you have this problem, add the following line into your bashrc:"
	echo
	elog "alias vlc='export XLIB_SKIP_ARGB_VISUALS=1; vlc; unset XLIB_SKIP_ARGB_VISUALS'"
	elog "see http://www.qtforum.org/article/26669/qt4-mess-up-the-opengl-context.html for more details."
}
