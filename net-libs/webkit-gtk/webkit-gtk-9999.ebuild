# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit git autotools flag-o-matic eutils virtualx

MY_P="webkit-${PV}"
DESCRIPTION="Open source web browser engine"
HOMEPAGE="http://www.webkitgtk.org/"

EGIT_REPO_URI="git://git.webkit.org/WebKit.git"
EGIT_PROJECT="webkit"
EGIT_BOOTSTRAP="NOCONFIGURE=1; ./autogen.sh"

LICENSE="LGPL-2 LGPL-2.1 BSD"
SLOT="2"
KEYWORDS="~amd64 ~x86"
IUSE="coverage debug doc +gstreamer +introspection +jit spell"

RDEPEND="
	dev-libs/libxml2:2
	dev-libs/libxslt
	virtual/jpeg
	media-libs/libpng:0
	x11-libs/cairo
	>=dev-libs/glib-2.27.90:2
	>=x11-libs/gtk+-3.0:3
	>=dev-libs/icu-3.8.1-r1
	>=net-libs/libsoup-2.33.6:2.4
	>=dev-db/sqlite-3
	>=x11-libs/pango-1.12

	gstreamer? (
		media-libs/gstreamer:0.10
		>=media-libs/gst-plugins-base-0.10.25:0.10 )

	introspection? (
		>=dev-libs/gobject-introspection-0.9.5 )

	spell? (
		>=app-text/enchant-0.22 )"

DEPEND="${RDEPEND}
	>=sys-devel/flex-2.5.33
	sys-devel/gettext
	dev-util/gperf
	dev-util/pkgconfig
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1.10 )
	test? ( x11-themes/hicolor-icon-theme )"


S="${WORKDIR}/${MY_P}"

pkg_setup() {
	ewarn "This is a huge package. If you do not have at least 1.25GB of free"
	ewarn "disk space in ${PORTAGE_TMPDIR} and also in ${DISTDIR} then"
	ewarn "you should abort this installation now and free up some space."
}

src_configure() {
	# It doesn't compile on alpha without this in LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	# Sigbuses on SPARC with mcpu
	use sparc && filter-flags "-mcpu=*" "-mvis" "-mtune=*"

	local myconf

	myconf="
		$(use_enable coverage)
		$(use_enable debug)
		$(use_enable spell spellcheck)
		$(use_enable introspection)
		$(use_enable gstreamer video)
		$(use_enable jit)
		--with-gtk=3.0
		--enable-3d-transforms
		--enable-media-statistics
                --disable-webgl
		--disable-webkit2
		--disable-web-sockets"

	econf ${myconf}
}

src_test() {
	unset DISPLAY
	# Tests will fail without it, bug 294691, bug 310695
	Xemake check || die "Test phase failed"
}

src_compile() {
	emake XDG_DATA_HOME="${T}/.local" || die "Compile failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	dodoc ChangeLog || die "dodoc failed"
}

pkg_postinst() {

	echo
	ewarn "This is experimental and NOT supported by gentoo."
	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	echo

}
