# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit cmake-utils cairo-dock

DESCRIPTION="Official plugins for cairo-dock subject to removal"
HOMEPAGE="http://www.glx-dock.org"

LICENSE="|| ( LGPL-2 LGPL-2.1 LGPL-3 ) GPL-2 GPL-3"
SLOT="0"
KEYWORDS="~amd64"
CD_PLUGIN_IUSE="netspeed wifi"
IUSE="${CD_PLUGIN_IUSE}"
REQUIRED_USE="|| ( ${CD_PLUGIN_IUSE} )"

RDEPEND="dev-libs/dbus-glib
	>=dev-libs/glib-2.22:2
	dev-libs/libxml2:2
	gnome-base/librsvg:2
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:2
	x11-libs/gtkglext
	~x11-misc/cairo-dock-${PV}"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	dev-util/pkgconfig"

pkg_setup() {
	use netspeed && CD_PLUGINS+=( "netspeed" )
	use wifi && CD_PLUGINS+=( "wifi" )
}

src_unpack() {
	cairo-dock_src_unpack
}

src_prepare() {
	cairo-dock_src_prepare
	use wifi && epatch "${FILESDIR}"/${PN}-fix-wifi-script.patch
}

src_configure() {
	mycmakeargs+=(
		"$(cmake-utils_use_enable netspeed NETSPEED)"
		"$(cmake-utils_use_enable wifi WIFI)"
	)
	cmake-utils_src_configure
}
