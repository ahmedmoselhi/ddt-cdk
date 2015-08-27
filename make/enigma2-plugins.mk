#
# tuxtxtlib
#
$(D)/tuxtxtlib: bootstrap @DEPENDS_tuxtxtlib@
	@PREPARE_tuxtxtlib@
	cd @DIR_tuxtxtlib@ && \
		aclocal && \
		autoheader && \
		autoconf && \
		automake --foreign --add-missing && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--with-boxtype=generic \
			--with-configdir=/etc \
			--with-datadir=/usr/share/tuxtxt \
			--with-fontdir=/usr/share/fonts && \
		$(MAKE) all && \
		@INSTALL_tuxtxtlib@
	@CLEANUP_tuxtxtlib@
	touch $@

#
# tuxtxt32bpp
#
$(D)/tuxtxt32bpp: tuxtxtlib @DEPENDS_tuxtxt32bpp@
	@PREPARE_tuxtxt32bpp@
	cd @DIR_tuxtxt32bpp@ && \
		aclocal && \
		autoheader && \
		autoconf && \
		automake --foreign --add-missing && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--with-boxtype=generic \
			--with-configdir=/etc \
			--with-datadir=/usr/share/tuxtxt \
			--with-fontdir=/usr/share/fonts && \
		$(MAKE) all && \
		@INSTALL_tuxtxt32bpp@
	@CLEANUP_tuxtxt32bpp@
	touch $@

#
# Plugins
# enigma2_openwebif
$(D)/enigma2-plugins: enigma2_networkbrowser enigma2_openwebif

#
# enigma2-openwebif
#
$(D)/enigma2_openwebif: $(D)/bootstrap $(D)/python $(D)/python_cheetah @DEPENDS_enigma2_openwebif@
	[ -d "$(archivedir)/e2openplugin-OpenWebif.git" ] && \
	(cd $(archivedir)/e2openplugin-OpenWebif.git; git pull ; git checkout HEAD; cd "$(buildprefix)";); \
	@PREPARE_enigma2_openwebif@
	cd @DIR_enigma2_openwebif@ && \
		$(BUILDENV) \
		cp -a plugin $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif && \
		mkdir -p $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/cs/LC_MESSAGES && \
		mkdir -p $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/de/LC_MESSAGES && \
		mkdir -p $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/el/LC_MESSAGES && \
		mkdir -p $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/nl/LC_MESSAGES && \
		mkdir -p $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/pl/LC_MESSAGES && \
		mkdir -p $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/uk/LC_MESSAGES && \
		msgfmt -cv -o $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/cs/LC_MESSAGES/OpenWebif.mo locale/cs.po && \
		msgfmt -cv -o $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/de/LC_MESSAGES/OpenWebif.mo locale/de.po && \
		msgfmt -cv -o $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/el/LC_MESSAGES/OpenWebif.mo locale/el.po && \
		msgfmt -cv -o $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/nl/LC_MESSAGES/OpenWebif.mo locale/nl.po && \
		msgfmt -cv -o $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/pl/LC_MESSAGES/OpenWebif.mo locale/pl.po && \
		msgfmt -cv -o $(targetprefix)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/uk/LC_MESSAGES/OpenWebif.mo locale/uk.po
	@CLEANUP_enigma2_openwebif@
	touch $@ || true

#
# enigma2-networkbrowser
#
$(D)/enigma2_networkbrowser: @DEPENDS_enigma2_networkbrowser@
	[ -d "$(archivedir)/enigma2-openpli-plugins-enigma2.git" ] && \
	(cd $(archivedir)/enigma2-openpli-plugins-enigma2.git; git pull ; git checkout HEAD; cd "$(buildprefix)";); \
	@PREPARE_enigma2_networkbrowser@
	cd @DIR_enigma2_networkbrowser@/src/lib && \
		$(BUILDENV) \
		sh4-linux-gcc -shared -o netscan.so \
			-I $(targetprefix)/usr/include/python$(PYTHON_VERSION) \
			-include Python.h \
			errors.h \
			list.c \
			list.h \
			main.c \
			nbtscan.c \
			nbtscan.h \
			range.c \
			range.h \
			showmount.c \
			showmount.h \
			smb.h \
			smbinfo.c \
			smbinfo.h \
			statusq.c \
			statusq.h \
			time_compat.h
	cd @DIR_enigma2_networkbrowser@ && \
		mkdir -p $(targetprefix)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser && \
		cp -a po $(targetprefix)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/ && \
		cp -a meta $(targetprefix)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/ && \
		cp -a src/* $(targetprefix)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/ && \
		cp -a src/lib/netscan.so $(targetprefix)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/ && \
		rm -rf $(targetprefix)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/lib
	@CLEANUP_enigma2_networkbrowser@
	touch $@ || true
