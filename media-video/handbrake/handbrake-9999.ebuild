# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

#ESVN_REPO_URI="svn://svn.handbrake.fr/HandBrake/trunk"
EGIT_REPO_URI="git://github.com/HandBrake/HandBrake.git"
EGIT_PROJECT="HandBrake"

#inherit subversion gnome2-utils
inherit git gnome2-utils

DESCRIPTION="Open-source DVD to MPEG-4 converter"
HOMEPAGE="http://handbrake.fr/"

ESVN_REPO_URI="svn://svn.handbrake.fr/HandBrake/trunk"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="css doc gtk"
#			sys-apps/hal
RDEPEND="sys-libs/zlib
	css? ( media-libs/libdvdcss )
	gtk? (	>=x11-libs/gtk+-2.8
			dev-libs/dbus-glib
			net-libs/webkit-gtk
			x11-libs/libnotify
			media-libs/gstreamer
			media-libs/gst-plugins-base
	)"
DEPEND="dev-lang/yasm
	dev-lang/python
	|| ( net-misc/wget net-misc/curl ) 
	${RDEPEND}"

#src_prepare() {
#	epatch "${FILESDIR}/${P}-build.patch"
#	epatch "${FILESDIR}/${P}-new_libnotify.patch"
#}

src_configure() {
	# Python configure script doesn't accept all econf flags
	./configure --force --prefix=/usr \
		$(use_enable gtk) \
		|| die "configure failed"
}

src_compile() {
	emake -j1 -C build || die "failed compiling ${PN}"
}

src_install() {
	emake -C build DESTDIR="${D}" install || die "failed installing ${PN}"

	if use doc; then
		emake -C build doc
		dodoc AUTHORS CREDITS NEWS THANKS \
			build/doc/articles/txt/* || die "docs failed"
	fi
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	echo
	ewarn "This is experimental and NOT supported by gentoo."
	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	echo
}

pkg_postrm() {
	gnome2_icon_cache_update
}
