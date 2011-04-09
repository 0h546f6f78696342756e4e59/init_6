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
SLOT="3"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
# aqua, geoclue
IUSE="coverage debug doc +gstreamer +introspection +jit spell"

# use sqlite, svg by default
# dependency on >=x11-libs/gtk+-2.13:2 for gail
# Aqua support in gtk3 is untested
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

	# Sigbuses on SPARC with mcpu and co.
	use sparc && filter-flags "-mcpu=*" "-mvis" "-mtune=*"

	# https://bugs.webkit.org/show_bug.cgi?id=42070 , #301634
	use ppc64 && append-flags "-mminimal-toc"

	local myconf

	# XXX: Check Web Audio support
	# XXX: webgl fails compilation
	# XXX: Wtf is WebKit2?
	
	myconf="
		$(use_enable coverage)
		$(use_enable debug)
		$(use_enable spell spellcheck)
		$(use_enable introspection)
		$(use_enable gstreamer video)
		$(use_enable jit)
		--disable-webgl
		--with-gtk=3.0
		--disable-webkit2
		--disable-web-sockets"
		# Aqua support in gtk3 is untested
		#$(use aqua && echo "--with-font-backend=pango --with-target=quartz")"
		# Disable web-sockets per bug #326547

	econf ${myconf}

	econf ${myconf}
}

src_compile() {
	# XXX: This step is required so we properly build gettext catalogs
	emake update-po || die "Compile failed"
	# Fix sandbox error with USE="introspection"
	# https://bugs.webkit.org/show_bug.cgi?id=35471
	emake XDG_DATA_HOME="${T}/.local" || die "Compile failed"
}

src_test() {
	unset DISPLAY
	# Tests need virtualx, bug #294691, bug #310695
	# Set XDG_DATA_HOME for introspection tools, bug #323669
	Xemake check XDG_DATA_HOME="${T}/.local" || die "Test phase failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	dodoc ChangeLog || die "dodoc failed"

	# Remove .la files
	find "${D}" -name '*.la' -exec rm -f '{}' + || die
}

pkg_postinst() {

	echo
	ewarn "This is experimental and NOT supported by gentoo."
	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	echo

}
