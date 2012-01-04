# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils rpm

DOWNLOAD_URL="http://www.draftsight.com/download-linux-fedora"
MY_PN="DraftSight"

DESCRIPTION="Professional-grade 2D CAD application"
HOMEPAGE="http://www.3ds.com/products/draftsight/overview/"
SRC_URI="${MY_PN}.rpm"

LICENSE="DraftSight"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="fetch strip"

DEPEND=""
RDEPEND=">=media-libs/nas-1.9.2"

S=${WORKDIR}

pkg_nofetch() {
	einfo "Please download ${A} from"
	einfo "${DOWNLOAD_URL}"
	einfo "(agree to the license) and place it in ${DISTDIR}"
}

src_install() {
	cp -pPR "${S}/opt" "${ED}/"

	# Preserve directories in /var/opt for something
	keepdir /var/opt/dassault-systemes/draftsight/license
	keepdir /var/opt/dassault-systemes/draftsight/settings

	dobin "${FILESDIR}/${PN}"
}
