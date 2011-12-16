# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: cairo-dock.eclass
# @MAINTAINER:
# dustin.polke@uni-siegen.de
#
# @CODE@
# Authors: Dustin Polke <dustin.polke@uni-siegen.de>.
# @CODE@
# @BLURB: Helper eclass for cairo-dock installation.
# @DESCRIPTION:
# Provide helper functions for cairo-dock and split cairo-dock-plugins ebuilds.

inherit versionator

# @ECLASS-VARIABLE: CD_P
# @DESCRIPTION:
# Upstream's name of the package
: ${CD_P:=${PN}-$(replace_version_separator 3 '~' )}

# @ECLASS-VARIABLE: CDP_P
# @INTERNAL
# @DESCRIPTION:
# Upstream's name of the plugin package
: ${CDP_P:=${PN%-*}-$(replace_version_separator 3 '~' )}
CDP_P=${CDP_P/cd/cairo-dock}

# @ECLASS-VARIABLE: CD_PV_MAJ_MIN
# @INTERNAL
# @DESCRIPTION:
# Major and minor numbers of the version number.
: ${CD_PV_MAJ_MIN:=$(get_version_component_range 1-2)}

# @ECLASS-VARIABLE: CD_PV_MAJ_MIN_MIC
# @INTERNAL
# @DESCRIPTION:
# Major, minor, and micro numbers of the version number.
: ${CD_PV_MAJ_MIN_MIC:=$(get_version_component_range 1-3)}

# @ECLASS-VARIABLE: CD_TYPE
# @INTERNAL
# @DESCRIPTION:
# Defines package type.
if [ "${CDP_P%-*}" == "cairo-dock-plugins" ]; then
	CD_TYPE="plug-ins"
	CD_P="${CDP_P}"
else
	CD_TYPE="core"
fi

# @ECLASS-VARIABLE: CD_PLUGINS
# @DESCRIPTION:
# Names of all plugins to be handled by the ebuild.

SRC_URI="http://launchpad.net/cairo-dock-${CD_TYPE}/${CD_PV_MAJ_MIN}/${CD_PV_MAJ_MIN_MIC}/+download/${CD_P}.tar.gz"

S="${WORKDIR}"/${CD_P}

# @FUNCTION: cairo-dock_src_unpack
# @DESCRIPTION:
# For plugins, unpack only code for plugins to be build; otherwise run
# default_src_unpack.
# Don't unpack CMakeLists.txt if ${FILESDIR}/${P}-CMakeLists.txt or
# ${FILESDIR}/${PN}-${CD_PV_MAJ_MIN_MIC}-CMakeLists.txt exist.
cairo-dock_src_unpack() {
	if [ "${CD_TYPE}" == "plug-ins" ]; then
		local target targets
		[ "${PN}" == "cd-plugins-core" ] && \
			targets+=( "${CDP_P}/po" )
		for target in ${CD_PLUGINS[@]}; do
			targets+=( "${CDP_P}/${target}" )
		done
		[ ! -f "${FILESDIR}"/${PN}-${CD_PV_MAJ_MIN_MIC}-CMakeLists.txt -a \
			! -f "${FILESDIR}"/${P}-CMakeLists.txt ] &&
			targets+=( "${CDP_P}/CMakeLists.txt" )
		einfo tar xzf "${DISTDIR}"/${CDP_P}.tar.gz ${targets[@]}
		tar xzf "${DISTDIR}"/${CDP_P}.tar.gz ${targets[@]} || die
	else
		default_src_unpack
	fi
}

# @FUNCTION: cairo-dock_src_unpack
# @DESCRIPTION:
# Apply CMakeLists.patch if it exists, and use ${FILESDIR}/${P}-CMakeLists.txt
# or ${FILESDIR}/${PN}-${CD_PV_MAJ_MIN_MIC}-CMakeLists.txt if they exit.
# Enable verbose building.
cairo-dock_src_prepare() {
	if [ -f "${FILESDIR}"/${P}-CMakeLists.patch ]; then
		epatch "${FILESDIR}"/${P}-CMakeLists.patch
	else
		if [ -f "${FILESDIR}"/${P}-CMakeLists.txt ]; then
			einfo "Copying ${P}-CMakeLists.txt from '${FILESDIR}'..."
			cp {"${FILESDIR}"/${P}-,"${S}"/}CMakeLists.txt || die
		else
			einfo "Copying ${PN}-${CD_PV_MAJ_MIN_MIC}-CMakeLists.txt from '${FILESDIR}'..."
			cp {"${FILESDIR}"/${PN}-${CD_PV_MAJ_MIN_MIC}-,"${S}"/}CMakeLists.txt || die
			einfo "Adjusting version to $(replace_version_separator 3 '~' )..."
			sed -e "s/@CD_VER@/$(replace_version_separator 3 '~' )/" \
				-i "${S}"/CMakeLists.txt
		fi
	fi
	mycmakeargs=( "-DCMAKE_VERBOSE_MAKEFILE=TRUE" )
}
