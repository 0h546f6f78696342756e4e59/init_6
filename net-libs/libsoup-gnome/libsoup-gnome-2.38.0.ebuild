# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
GCONF_DEBUG="yes"
GNOME2_LA_PUNT="yes"

MY_PN=${PN/-gnome}
MY_P=${MY_PN}-${PV}

inherit autotools eutils gnome2
if [[ ${PV} = 9999 ]]; then
	GNOME_LIVE_MODULE=${MY_PN}
	inherit gnome2-live
fi

DESCRIPTION="GNOME plugin for libsoup"
HOMEPAGE="http://live.gnome.org/LibSoup"
SRC_URI="${SRC_URI//-gnome}"

LICENSE="LGPL-2"
SLOT="2.4"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-solaris"
fi
IUSE="debug doc +introspection"

RDEPEND="~net-libs/libsoup-${PV}
	|| ( gnome-base/libgnome-keyring <gnome-base/gnome-keyring-2.29.4 )
	dev-db/sqlite:3
	introspection? ( >=dev-libs/gobject-introspection-0.9.5 )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	>=dev-util/gtk-doc-am-1.10
	doc? ( >=dev-util/gtk-doc-1.10 )"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-static
		--disable-tls-check
		$(use_enable introspection)
		--with-libsoup-system
		--with-gnome"
	DOCS="AUTHORS NEWS README"
}

src_configure() {
	# FIXME: we need addpredict to workaround bug #324779 until
	# root cause (bug #249496) is solved
	addpredict /usr/share/snmp/mibs/.index
	gnome2_src_configure
}

src_prepare() {
	gnome2_src_prepare

	# Use lib present on the system
	epatch "${FILESDIR}"/${PN}-system-lib.patch
	eautoreconf
}
