#
#
#
STM_RELOCATE = /opt/STM/STLinux-2.4
STMKERNEL_VER = 2.6.32.46-48

# 4.6.3
#BINUTILS_VER = 2.22-64
#GCC_VER = 4.6.3-111
#LIBGCC_VER = 4.6.3-111
#GLIBC_VER = 2.10.2-42

# 4.7.2
#BINUTILS_VER  = 2.23.2-68
#GCC_VER       = 4.7.2-119
#LIBGCC_VER    = 4.7.2-124
#GLIBC_VER     = 2.10.2-43

# 4.7.3
#BINUTILS_VER  = 2.23.2-68
#GCC_VER       = 4.7.3-124
#LIBGCC_VER    = 4.7.3-129
#GLIBC_VER     = 2.10.2-43

# 4.8.3
#BINUTILS_VER  = 2.24.51.0.3-75
#GCC_VER       = 4.8.3-138
#LIBGCC_VER    = 4.8.3-147
#GLIBC_VER     = 2.14.1-51

# 4.8.2
#BINUTILS_VER  = 2.23.2-73
#GCC_VER       = 4.8.2-131
#LIBGCC_VER    = 4.8.2-138
#GLIBC_VER     = 2.14.1-50

# 4.8.4
BINUTILS_VER  = 2.24.51.0.3-77
GCC_VER       = 4.8.4-139
LIBGCC_VER    = 4.8.4-149
GLIBC_VER     = 2.14.1-56

$(hostprefix)/bin/unpack-rpm.sh:
	ln -sf $(buildprefix)/scripts/$(shell basename $@) $(hostprefix)/bin

crosstool-rpminstall: \
$(archivedir)/stlinux24-cross-sh4-binutils-$(BINUTILS_VER).i386.rpm \
$(archivedir)/stlinux24-cross-sh4-binutils-dev-$(BINUTILS_VER).i386.rpm \
$(archivedir)/stlinux24-cross-sh4-cpp-$(GCC_VER).i386.rpm \
$(archivedir)/stlinux24-cross-sh4-gcc-$(GCC_VER).i386.rpm \
$(archivedir)/stlinux24-cross-sh4-g++-$(GCC_VER).i386.rpm \
$(archivedir)/stlinux24-sh4-linux-kernel-headers-$(STMKERNEL_VER).noarch.rpm \
$(archivedir)/stlinux24-sh4-glibc-$(GLIBC_VER).sh4.rpm \
$(archivedir)/stlinux24-sh4-glibc-dev-$(GLIBC_VER).sh4.rpm \
$(archivedir)/stlinux24-sh4-libgcc-$(LIBGCC_VER).sh4.rpm \
$(archivedir)/stlinux24-sh4-libstdc++-$(LIBGCC_VER).sh4.rpm \
$(archivedir)/stlinux24-sh4-libstdc++-dev-$(LIBGCC_VER).sh4.rpm
	unpack-rpm.sh $(buildtmp) $(STM_RELOCATE)/devkit/sh4 $(crossprefix) \
		$^
	touch .deps/$@

# install the RPMs
crosstool: directories \
$(hostprefix)/bin/unpack-rpm.sh \
crosstool-rpminstall
	if [ -e $(crossprefix)/target/usr/lib/libstdc++.la ]; then \
		sed -i "s,^libdir=.*,libdir='$(crossprefix)/target/usr/lib'," $(crossprefix)/target/usr/lib/lib{std,sup}c++.la; \
	fi
	if test -e $(crossprefix)/target/usr/lib/libstdc++.so; then \
		cp -a $(crossprefix)/target/usr/lib/libstdc++.s*[!y] $(targetprefix)/lib; \
		cp -a $(crossprefix)/target/usr/lib/libdl.so $(targetprefix)/usr/lib; \
		cp -a $(crossprefix)/target/usr/lib/libm.so $(targetprefix)/usr/lib; \
		cp -a $(crossprefix)/target/usr/lib/librt.so $(targetprefix)/usr/lib; \
		cp -a $(crossprefix)/target/usr/lib/libutil.so $(targetprefix)/usr/lib; \
		cp -a $(crossprefix)/target/usr/lib/libpthread.so $(targetprefix)/usr/lib; \
		cp -a $(crossprefix)/target/usr/lib/libresolv.so $(targetprefix)/usr/lib; \
		ln -s $(crossprefix)/target/usr/lib/libc.so $(targetprefix)/usr/lib/libc.so; \
		ln -s $(crossprefix)/target/usr/lib/libc_nonshared.a $(targetprefix)/usr/lib/libc_nonshared.a; \
	fi
	if test -e $(crossprefix)/target/lib; then \
		cp -a $(crossprefix)/target/lib/*so* $(targetprefix)/lib; \
	fi
	if test -e $(crossprefix)/target/sbin/ldconfig; then \
		cp -a $(crossprefix)/target/sbin/ldconfig $(targetprefix)/sbin; \
		cp -a $(crossprefix)/target/etc/ld.so.conf $(targetprefix)/etc; \
		cp -a $(crossprefix)/target/etc/host.conf $(targetprefix)/etc; \
	fi
	touch .deps/$@

#
# FILESYSTEM
#
$(D)/directories:
	$(INSTALL) -d $(targetprefix)
	$(INSTALL) -d $(crossprefix)
	$(INSTALL) -d $(bootprefix)
	$(INSTALL) -d $(hostprefix)
	$(INSTALL) -d $(hostprefix)/{bin,lib,share}
	$(INSTALL) -d $(targetprefix)/{bin,boot,etc,lib,sbin,tmp,usr,var}
	$(INSTALL) -d $(targetprefix)/etc/{init.d,mdev,network,rc.d}
	$(INSTALL) -d $(targetprefix)/etc/rc.d/{rc0.d,rc1.d,rc2.d,rc3.d,rc4.d,rc5.d,rc6.d,rcS.d}
	ln -s ../init.d $(targetprefix)/etc/rc.d/init.d
	$(INSTALL) -d $(targetprefix)/lib/lsb
	$(INSTALL) -d $(targetprefix)/usr/{bin,lib,local,sbin,share}
	$(INSTALL) -d $(targetprefix)/usr/lib/pkgconfig
	$(INSTALL) -d $(targetprefix)/usr/include/linux
	$(INSTALL) -d $(targetprefix)/usr/include/linux/dvb
	$(INSTALL) -d $(targetprefix)/usr/local/{bin,sbin,share}
	$(INSTALL) -d $(targetprefix)/var/{etc,lib,run}
	$(INSTALL) -d $(targetprefix)/var/lib/{misc,nfs}
	$(INSTALL) -d $(targetprefix)/var/bin
	touch $@

