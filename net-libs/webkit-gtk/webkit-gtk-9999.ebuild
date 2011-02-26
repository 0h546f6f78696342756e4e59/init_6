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
# aqua, geoclue
IUSE="coverage debug doc +gstreamer +introspection +jit"

# use sqlite, svg by default
# dependency on >=x11-libs/gtk+-2.13:2 for gail
# XXX: Quartz patch does not apply
# >=x11-libs/gtk+-2.13:2[aqua=]
#	>=dev-libs/glib-2.25 (only needed when using gsettings)
RDEPEND="
	dev-libs/libxml2
	dev-libs/libxslt
	media-libs/jpeg:0
	media-libs/libpng
	x11-libs/cairo
	>=x11-libs/gtk+-2.13:2
	>=dev-libs/icu-3.8.1-r1
	>=net-libs/libsoup-2.29.90
	>=dev-db/sqlite-3
	>=app-text/enchant-0.22
	>=x11-libs/pango-1.12

	gstreamer? (
		media-libs/gstreamer:0.10
		>=media-libs/gst-plugins-base-0.10.25:0.10 )

	introspection? (
		>=dev-libs/gobject-introspection-0.9.5 )"

DEPEND="${RDEPEND}
	>=sys-devel/flex-2.5.33
	sys-devel/gettext
	dev-util/gperf
	dev-util/pkgconfig
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1.10 )"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	ewarn "This is a huge package. If you do not have at least 1.25GB of free"
	ewarn "disk space in ${PORTAGE_TMPDIR} and also in ${DISTDIR} then"
	ewarn "you should abort this installation now and free up some space."
}

#src_prepare() {
	# FIXME: Fix unaligned accesses on ARM, IA64 and SPARC
	# https://bugs.webkit.org/show_bug.cgi?id=19775
#	use sparc && epatch "${FILESDIR}"/${PN}-1.1.15.2-unaligned.patch

	# Darwin/Aqua build is broken, needs autoreconf
	# XXX: BROKEN. Patch does not apply anymore.
	# https://bugs.webkit.org/show_bug.cgi?id=28727
	#epatch "${FILESDIR}"/${PN}-1.1.15.4-darwin-quartz.patch

	# Don't force -O2
#	sed -i 's/-O2//g' "${S}"/configure.ac || die "sed failed"
	# Prevent maintainer mode from being triggered during make
#	AT_M4DIR=Source/autotools eautoreconf
#}

src_configure() {
	# It doesn't compile on alpha without this in LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	# Sigbuses on SPARC with mcpu
	use sparc && filter-flags "-mcpu=*" "-mvis" "-mtune=*"

	local myconf

	# XXX: Check Web Audio support
	# XXX: websockets disabled due to security issue in protocol
	# XXX: Wtf is WebKit2?
	# XXX: 3D canvas fails to compile
	myconf="
		$(use_enable coverage)
		$(use_enable debug)
		$(use_enable introspection)
		$(use_enable gstreamer video)
		$(use_enable jit)
		--with-gtk=2.0
		--enable-spellcheck
		--enable-3d-transforms
--enable-media-statistics
--enable-directory-upload
--enable-file-system
		--disable-webkit2
		--disable-web-sockets"
		#--enable-notifications
		#--enable-datagrid
		#--enable-indexed-database
		#--enable-xhtmlmp
		# quartz patch above does not apply anymore
		#$(use aqua && echo "--with-target=quartz")"

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
#	dodoc WebKit/gtk/{NEWS,ChangeLog} || die "dodoc failed"
	dodoc ChangeLog || die "dodoc failed"
}

pkg_postinst() {

	echo
	ewarn "This is experimental and NOT supported by gentoo."
	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	echo

}
