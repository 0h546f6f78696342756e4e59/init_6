# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
PYTHON_DEPEND="python? 2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit cmake-utils cairo-dock python

DESCRIPTION="Official recommended plugins for cairo-dock"
HOMEPAGE="http://www.glx-dock.org"

LICENSE="|| ( LGPL-2 LGPL-2.1 LGPL-3 ) GPL-2 GPL-3"
SLOT="0"
KEYWORDS="~amd64"
CD_PLUGINS_IUSE="gnome xfce"
IUSE="${CD_PLUGINS_IUSE} mono python ruby vala"

RDEPEND="dev-libs/dbus-glib
	>=dev-libs/glib-2.22:2
	dev-libs/libxml2:2
	gnome-base/librsvg:2
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:2
	x11-libs/gtkglext
	~x11-misc/cairo-dock-${PV}
	mono? ( dev-dotnet/glib-sharp
		dev-dotnet/ndesk-dbus
		dev-dotnet/ndesk-dbus-glib
		dev-lang/mono )
	ruby? ( dev-lang/ruby )
	vala? ( dev-lang/vala
		>=dev-libs/glib-2.26:2 )
	xfce? ( xfce-extra/thunar-vfs )
	!x11-misc/cairo-dock-plugins"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	dev-util/pkgconfig"

pkg_setup() {
	CD_PLUGINS=(
		"dock-rendering"
		"desklet-rendering"
		"dialog-rendering"
		"Dbus"
		"Animated-icons"
		"icon-effect"
		"illusion"
		"drop-indicator"
	)
	use gnome && CD_PLUGINS+=( "gnome-integration" )
	use xfce && CD_PLUGINS+=( "xfce-integration" )
	use gnome || use xfce && CD_PLUGINS+=( "gvfs-integration" )
}

src_unpack() {
	cairo-dock_src_unpack
}

src_prepare() {
	cairo-dock_src_prepare
	epatch "${FILESDIR}"/${P}-Dbus_CMakeLists.patch
	use xfce && epatch "${FILESDIR}"/${P}-xfce-integration_CMakeLists.patch
	use python && python_copy_sources Dbus/interfaces/{bash,python}
}

src_configure() {
	mycmakeargs+=(
		"$(cmake-utils_use_enable gnome GNOME-INTEGRATION)"
		"$(cmake-utils_use_enable xfce XFCE-INTEGRATION)"
		"$(cmake-utils_use_with mono MONO-INTERFACE)"
		"$(cmake-utils_use_with python PYTHON-INTERFACE)"
		"$(cmake-utils_use_with ruby RUBY-INTERFACE)"
		"$(cmake-utils_use_with vala VALA-INTERFACE)"
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use python; then
		build_bindings() {
			"$(PYTHON)" setup.py -q build
		}
		local target sdir="Dbus/interfaces/"
		for target in "bash" "python"; do
			python_execute_function -s --source-dir ${sdir}${target} build_bindings
		done
	fi
}

src_install() {
	cmake-utils_src_install

	if use python; then
		install_bindings() {
			insinto "$(python_get_sitedir)"/cairodock
			doins build/lib/*.py
			touch "${D}/$(python_get_sitedir)"/cairodock/__init__.py
		}
		local target sdir="Dbus/interfaces/"
		for target in "bash" "python"; do
			python_execute_function -s --source-dir ${sdir}${target} install_bindings
		done
	fi
}

pkg_postinst() {
	use python && python_mod_optimize cairodock
}

pkg_postrm() {
	use python && python_mod_cleanup cairodock
}
