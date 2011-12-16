# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit cmake-utils cairo-dock

DESCRIPTION="Official unstable plugins for cairo-dock"
HOMEPAGE="http://www.glx-dock.org"

LICENSE="|| ( LGPL-2 LGPL-2.1 LGPL-3 ) GPL-2 GPL-3"
SLOT="0"
KEYWORDS="~amd64"
CD_PLUGIN_IUSE="disks doncky network-monitor scoobydo" #kde"
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
	use disks && CD_PLUGINS+=( "Disks" )
	use doncky && CD_PLUGINS+=( "Doncky" )
#	use kde && CD_PLUGINS+=( "kde-integration" ) #"gvfs-integration" )
	use network-monitor && CD_PLUGINS+=( "Network-Monitor" )
	use scoobydo && CD_PLUGINS+=( "Scooby-Do" )
}

src_unpack() {
	cairo-dock_src_unpack
}

src_prepare() {
	cairo-dock_src_prepare
}

src_configure() {
#		"$(cmake-utils_use_enable kde KDE-INTEGRATION)"
	mycmakeargs+=(
		"$(cmake-utils_use_enable disks DISKS-PLUGIN)"
		"$(cmake-utils_use_enable doncky DONCKY-PLUGIN)"
		"$(cmake-utils_use_enable network-monitor NETWORK-MONITOR-PLUGIN)"
		"$(cmake-utils_use_enable scoobydo SCOOBY-DO-PLUGIN)"
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
