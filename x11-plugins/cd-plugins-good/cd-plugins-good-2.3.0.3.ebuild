# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# needs python handling added and then install Dbus python scripts

EAPI="4"

inherit cmake-utils cairo-dock

DESCRIPTION="Official plugins for cairo-dock with minor flaws."
HOMEPAGE="http://www.glx-dock.org"

LICENSE="|| ( LGPL-2 LGPL-2.1 LGPL-3 ) GPL-2 GPL-3"
SLOT="0"
KEYWORDS="~amd64"
CD_PLUGIN_IUSE="dnd2share folders lm_sensors mail musicplayer recent-events
	remote-control rssreader stack status-notifier systray tomboy xklavier"
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
	~x11-misc/cairo-dock-${PV}
	lm_sensors? ( sys-apps/lm_sensors )
	mail? ( net-libs/libetpan )
	recent-events? ( dev-libs/libzeitgeist )
	status-notifier? ( dev-libs/libdbusmenu[gtk] )
	xklavier? ( x11-libs/libxklavier )"

DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	dev-util/pkgconfig"

pkg_setup() {
	use dnd2share && CD_PLUGINS+=( "dnd2share" )
	use folders && CD_PLUGINS+=( "Folders ")
	use mail && CD_PLUGINS+=( "mail" )
	use musicplayer && CD_PLUGINS+=( "musicPlayer" )
	use recent-events && CD_PLUGINS+=( "Recent-Events" )
	use remote-control && CD_PLUGINS+=( "Remote-Control" )
	use rssreader && CD_PLUGINS+=( "RSSreader" )
	use stack && CD_PLUGINS+=( "stack" )
	use status-notifier && CD_PLUGINS+=( "Status-Notifier" )
	use lm_sensors && CD_PLUGINS+=( "System-Monitor" "cmake_modules" )
	use systray && CD_PLUGINS+=( "systray" )
	use tomboy && CD_PLUGINS+=( "tomboy" )
	use xklavier && CD_PLUGINS+=( "keyboard-indicator" )
}

src_unpack() {
	cairo-dock_src_unpack
}

src_prepare() {
	cairo-dock_src_prepare
}

src_configure() {
	mycmakeargs+=(
		"$(cmake-utils_use_enable dnd2share DND2SHARE-PLUGIN)"
		"$(cmake-utils_use_enable folders FOLDERS-PLUGIN)"
		"$(cmake-utils_use_enable xklavier KEYBOARD-INDICATOR-PLUGIN)"
		"$(cmake-utils_use_enable mail MAIL-PLUGIN)"
		"$(cmake-utils_use_enable musicplayer MUSICPLAYER-PLUGIN)"
		"$(cmake-utils_use_enable recent-events RECENT-EVENTS-PLUGIN)"
		"$(cmake-utils_use_enable remote-control REMOTE-CONTROL-PLUGIN)"
		"$(cmake-utils_use_enable rssreader RSSREADER-PLUGIN)"
		"$(cmake-utils_use_enable stack STACK-PLUGIN)"
		"$(cmake-utils_use_enable status-notifier STATUS-NOTIFIER-PLUGIN)"
		"$(cmake-utils_use_enable lm_sensors SYSTEM-MONITOR-PLUGIN)"
		"$(cmake-utils_use_enable systray SYSTRAY-PLUGIN)"
		"$(cmake-utils_use_enable tomboy TOMBOY-PLUGIN)"
		)
	cmake-utils_src_configure
}
