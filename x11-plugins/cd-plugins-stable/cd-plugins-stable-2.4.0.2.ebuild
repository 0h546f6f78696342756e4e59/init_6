# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit cmake-utils cairo-dock

DESCRIPTION="Official stable plugins for cairo-dock"
HOMEPAGE="http://www.glx-dock.org"

LICENSE="|| ( LGPL-2 LGPL-2.1 LGPL-3 ) GPL-2 GPL-3"
SLOT="0"
KEYWORDS="~amd64"
CD_PLUGIN_IUSE="alsa clipper clock dustbin gmenu kde logout motion-blur penguin
	powermanager quickbrowser shortcuts showdesktop showmouse slider switcher
	terminal toons weather webkit xgamma"
IUSE="${CD_PLUGIN_IUSE} exif ical upower xrandr"
REQUIRED_USE="|| ( ${CD_PLUGIN_IUSE} )
	exif? ( slider )
	ical? ( clock )
	upower? ( logout )
	xrandr? ( showdesktop )"

RDEPEND="dev-libs/dbus-glib
	>=dev-libs/glib-2.22:2
	dev-libs/libxml2:2
	gnome-base/librsvg:2
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:2
	x11-libs/gtkglext
	~x11-misc/cairo-dock-${PV}
	alsa? ( media-libs/alsa-lib )
	exif? ( media-libs/libexif )
	gmenu? ( gnome-base/gnome-menus )
	ical? ( dev-libs/libical )
	terminal? ( x11-libs/vte )
	upower? ( sys-power/upower )
	webkit? ( >=net-libs/webkit-gtk-1.0:2 )
	xgamma? ( x11-libs/libXxf86vm )
	xrandr? ( x11-libs/libXrandr )"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	dev-util/pkgconfig"

pkg_setup() {
	use alsa && CD_PLUGINS+=( "alsaMixer" )
	use clipper && CD_PLUGINS+=( "Clipper" )
	use clock && CD_PLUGINS+=( "clock" )
	use dustbin && CD_PLUGINS+=( "dustbin" )
	use gmenu && CD_PLUGINS+=( "GMenu" )
	use kde && CD_PLUGINS+=( "kde-integration" "gvfs-integration" )
	use logout && CD_PLUGINS+=( "logout" )
	use motion-blur && CD_PLUGINS+=( "motion-blur" )
	use penguin && CD_PLUGINS+=( "Cairo-Penguin" )
	use powermanager && CD_PLUGINS+=( "powermanager" )
	use quickbrowser && CD_PLUGINS+=( "quick-browser" )
	use shortcuts && CD_PLUGINS+=( "shortcuts" )
	use showdesktop && CD_PLUGINS+=( "showDesktop" )
	use showmouse && CD_PLUGINS+=( "show-mouse" )
	use slider && CD_PLUGINS+=( "slider" )
	use switcher && CD_PLUGINS+=( "switcher" )
	use terminal && CD_PLUGINS+=( "terminal" )
	use toons && CD_PLUGINS+=( "Toons" )
	use weather && CD_PLUGINS+=( "weather" )
	use webkit && CD_PLUGINS+=( "weblets" )
	use xgamma && CD_PLUGINS+=( "Xgamma" )
}

src_unpack() {
	cairo-dock_src_unpack
}

src_prepare() {
	cairo-dock_src_prepare
}

src_configure() {
	mycmakeargs+=(
		"$(cmake-utils_use_enable alsa ALSA-MIXER-PLUGIN)"
		"$(cmake-utils_use_enable penguin CAIRO-PENGUIN-PLUGIN)"
		"$(cmake-utils_use_enable clipper CLIPPER-PLUGIN)"
		"$(cmake-utils_use_enable clock CLOCK-PLUGIN)"
		"$(cmake-utils_use_with ical ICAL-SUPPORT)"
		"$(cmake-utils_use_enable dustbin DUSTBIN-PLUGIN)"
		"$(cmake-utils_use_enable gmenu GMENU-PLUGIN)"
		"$(cmake-utils_use_enable kde KDE-INTEGRATION)"
		"$(cmake-utils_use_enable logout LOGOUT-PLUGIN)"
		"$(cmake-utils_use_with upower UPOWER-SUPPORT)"
		"$(cmake-utils_use_enable motion-blur MOTION-BLUR-PLUGIN)"
		"$(cmake-utils_use_enable powermanager POWERMANAGER-PLUGIN)"
		"$(cmake-utils_use_enable quickbrowser QUICK-BROWSER-PLUGIN)"
		"$(cmake-utils_use_enable shortcuts SHORTCUTS-PLUGIN)"
		"$(cmake-utils_use_enable showdesktop SHOW-DESKTOP-PLUGIN)"
		"$(cmake-utils_use_with xrandr XRANDR-SUPPORT)"
		"$(cmake-utils_use_enable showmouse SHOW-MOUSE-PLUGIN)"
		"$(cmake-utils_use_enable slider SLIDER-PLUGIN)"
		"$(cmake-utils_use_with exif EXIF-SUPPORT)"
		"$(cmake-utils_use_enable switcher SWITCHER-PLUGIN)"
		"$(cmake-utils_use_enable terminal TERMINAL-PLUGIN)"
		"$(cmake-utils_use_enable toons TOONS-PLUGIN)"
		"$(cmake-utils_use_enable weather WEATHER-PLUGIN)"
		"$(cmake-utils_use_enable webkit WEBLETS-PLUGIN)"
		"$(cmake-utils_use_enable xgamma XGAMMA-PLUGIN)"
	)
	cmake-utils_src_configure
}

pkg_postinst() {
	elog "Compiz-Icon applet has been replaced by Composite-Manager applet,"
	elog "which is part of x11-plugins/cd-plugins-good."
}
