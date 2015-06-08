# Copyright 2015 EE-IX GNU/Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

eutils flag-o-matic prefix 

DESCRIPTION="File transfer program to keep remote files into sync"
HOMEPAGE="http://rsync.samba.org/"
SRC_URI="https://www.samba.org/ftp/rsync/src/${P/_/}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"


src_configure() {
	econf \
		--without-included-zlib \
		--without-included-popt \
		--with-rsyncd-conf="${EPREFIX}"/etc/rsyncd.conf
}

src_install() {
	emake DESTDIR="${D}" install
	newconfd "${FILESDIR}"/rsyncd.conf.d rsyncd
	newinitd "${FILESDIR}"/rsyncd.init.d rsyncd
	dodoc NEWS OLDNEWS README TODO tech_report.tex
	insinto /etc
	newins "${FILESDIR}"/rsyncd.conf-3.1.1 rsyncd.conf

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/rsyncd.logrotate rsyncd

	insinto /etc/xinetd.d
	newins "${FILESDIR}"/rsyncd.xinetd-3.1.1 rsyncd

	# Install the useful contrib scripts
	exeinto /usr/share/rsync
	doexe support/*
	rm -f "${ED}"/usr/share/rsync/{Makefile*,*.c}

	eprefixify "${ED}"/etc/{,xinetd.d}/rsyncd*

}

pkg_postinst() {
	if egrep -qis '^[[:space:]]use chroot[[:space:]]*=[[:space:]]*(no|0|false)' \
		"${EROOT}"/etc/rsyncd.conf "${EROOT}"/etc/rsync/rsyncd.conf ; then
		ewarn "You have disabled chroot support in your rsyncd.conf.  This"
		ewarn "is a security risk which you should fix.  Please check your"
		ewarn "/etc/rsyncd.conf file and fix the setting 'use chroot'."
	fi
}
