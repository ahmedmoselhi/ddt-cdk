#
# host_python
#
$(D)/host_python: @DEPENDS_host_python@
	@PREPARE_host_python@ && \
	( cd @DIR_host_python@ && \
		autoconf && \
		CONFIG_SITE= \
		OPT="$(HOST_CFLAGS)" \
		./configure \
			--without-cxx-main \
			--with-threads \
		&& \
		$(MAKE) python Parser/pgen && \
		mv python ./hostpython && \
		mv Parser/pgen ./hostpgen && \
		\
		$(MAKE) distclean && \
		./configure \
			--prefix=$(hostprefix) \
			--sysconfdir=$(hostprefix)/etc \
			--without-cxx-main \
			--with-threads \
		&& \
		$(MAKE) all install && \
		cp ./hostpgen $(hostprefix)/bin/pgen ) && \
	@CLEANUP_host_python@
	touch $@

#
# python
#
$(D)/python: $(D)/bootstrap $(D)/host_python $(D)/libncurses $(D)/zlib $(OPENSSL) $(D)/libffi $(D)/bzip2 $(D)/libreadline $(D)/sqlite @DEPENDS_python@
	@PREPARE_python@
	( cd @DIR_python@ && \
		CONFIG_SITE= \
		$(BUILDENV) \
		autoreconf --verbose --install --force Modules/_ctypes/libffi && \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=/usr \
			--sysconfdir=/etc \
			--enable-shared \
			--enable-ipv6 \
			--with-threads \
			--with-pymalloc \
			--with-signal-module \
			--with-wctype-functions \
			ac_sys_system=Linux \
			ac_sys_release=2 \
			ac_cv_file__dev_ptmx=no \
			ac_cv_file__dev_ptc=no \
			ac_cv_no_strict_aliasing_ok=yes \
			ac_cv_pthread=yes \
			ac_cv_cxx_thread=yes \
			ac_cv_sizeof_off_t=8 \
			ac_cv_have_chflags=no \
			ac_cv_have_lchflags=no \
			ac_cv_py_format_size_t=yes \
			ac_cv_broken_sem_getvalue=no \
			HOSTPYTHON=$(hostprefix)/bin/python \
		&& \
		$(MAKE) $(MAKE_OPTS) \
			PYTHON_MODULES_INCLUDE="$(targetprefix)/usr/include" \
			PYTHON_MODULES_LIB="$(targetprefix)/usr/lib" \
			PYTHON_XCOMPILE_DEPENDENCIES_PREFIX="$(targetprefix)" \
			CROSS_COMPILE_TARGET=yes \
			CROSS_COMPILE=$(target) \
			MACHDEP=linux2 \
			HOSTARCH=$(target) \
			CFLAGS="$(TARGET_CFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			LD="$(target)-gcc" \
			HOSTPYTHON=$(hostprefix)/bin/python \
			HOSTPGEN=$(hostprefix)/bin/pgen \
			all install DESTDIR=$(targetprefix) \
		) && \
		@INSTALL_python@
	$(LN_SF) ../../libpython$(PYTHON_VERSION).so.1.0 $(targetprefix)/$(PYTHON_DIR)/config/libpython$(PYTHON_VERSION).so && \
	$(LN_SF) $(targetprefix)/$(PYTHON_INCLUDE_DIR) $(targetprefix)/usr/include/python
	@CLEANUP_python@
	touch $@

#
# python_setuptools
#
$(D)/python_setuptools: $(D)/bootstrap $(D)/python @DEPENDS_python_setuptools@
	@PREPARE_python_setuptools@
	cd @DIR_python_setuptools@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_setuptools@
	touch $@

#
# libxmlccwrap
#
$(D)/libxmlccwrap: $(D)/bootstrap $(D)/libxml2_e2 $(D)/libxslt @DEPENDS_libxmlccwrap@
	@PREPARE_libxmlccwrap@
	cd @DIR_libxmlccwrap@ && \
		$(CONFIGURE) \
			--target=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libxmlccwrap@
	@CLEANUP_libxmlccwrap@
	touch $@

#
# python_lxml
#
$(D)/python_lxml: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_lxml@
	@PREPARE_python_lxml@
	cd @DIR_python_lxml@ && \
		$(PYTHON_BUILD) \
			--with-xml2-config=$(hostprefix)/bin/xml2-config \
			--with-xslt-config=$(hostprefix)/bin/xslt-config && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_lxml@
	touch $@

#
# python_twisted
#
$(D)/python_twisted: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_twisted@
	@PREPARE_python_twisted@
	cd @DIR_python_twisted@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_twisted@
	touch $@

#
# python_imaging
#
$(D)/python_imaging: $(D)/bootstrap $(D)/libjpeg $(D)/libfreetype $(D)/python $(D)/python_setuptools @DEPENDS_python_imaging@
	@PREPARE_python_imaging@
	cd @DIR_python_imaging@ && \
		sed -ie "s|"darwin"|"darwinNot"|g" "setup.py"; \
		sed -ie "s|ZLIB_ROOT = None|ZLIB_ROOT = libinclude(\"${targetprefix}/usr\")|" "setup.py"; \
		$(PYTHON_INSTALL)
	@CLEANUP_python_imaging@
	touch $@

#
# python_pycrypto
#
$(D)/python_pycrypto: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_pycrypto@
	@PREPARE_python_pycrypto@
	cd @DIR_python_pycrypto@ && \
		$(CONFIGURE) \
			--prefix=/usr && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_pycrypto@
	touch $@

#
# python_pyusb
#
$(D)/python_pyusb: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_pyusb@
	@PREPARE_python_pyusb@
	cd @DIR_python_pyusb@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_pyusb@
	touch $@

#
# python_six
#
$(D)/python_six: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_six@
	@PREPARE_python_six@
	cd @DIR_python_six@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_six@
	touch $@

#
# python_cffi
#
$(D)/python_cffi: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_cffi@
	@PREPARE_python_cffi@
	cd @DIR_python_cffi@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_cffi@
	touch $@

#
# python_enum34
#
$(D)/python_enum34: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_enum34@
	@PREPARE_python_enum34@
	cd @DIR_python_enum34@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_enum34@
	touch $@

#
# python_pyasn1_modules
#
$(D)/python_pyasn1_modules: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_pyasn1_modules@
	@PREPARE_python_pyasn1_modules@
	cd @DIR_python_pyasn1_modules@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_pyasn1_modules@
	touch $@

#
# python_pyasn1
#
$(D)/python_pyasn1: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_pyasn1_modules @DEPENDS_python_pyasn1@
	@PREPARE_python_pyasn1@
	cd @DIR_python_pyasn1@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_pyasn1@
	touch $@

#
# python_pycparser
#
$(D)/python_pycparser: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_pyasn1 @DEPENDS_python_pycparser@
	@PREPARE_python_pycparser@
	cd @DIR_python_pycparser@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_pycparser@
	touch $@

#
# python_cryptography
#
$(D)/python_cryptography: $(D)/bootstrap $(D)/libffi $(D)/python $(D)/python_setuptools $(D)/python_pyopenssl $(D)/python_six $(D)/python_pycparser @DEPENDS_python_cryptography@
	@PREPARE_python_cryptography@
	cd @DIR_python_cryptography@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_cryptography@
	touch $@

#
# python_pyopenssl
#
$(D)/python_pyopenssl: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_pyopenssl@
	@PREPARE_python_pyopenssl@
	cd @DIR_python_pyopenssl@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_pyopenssl@
	touch $@

#
# python_elementtree
#
$(D)/python_elementtree: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_elementtree@
	@PREPARE_python_elementtree@
	cd @DIR_python_elementtree@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_elementtree@
	touch $@

#
# python_wifi
#
$(D)/python_wifi: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_wifi@
	@PREPARE_python_wifi@
	cd @DIR_python_wifi@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_wifi@
	touch $@

#
# python_cheetah
#
$(D)/python_cheetah: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_cheetah@
	@PREPARE_python_cheetah@
	cd @DIR_python_cheetah@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_cheetah@
	touch $@

#
# python_mechanize
#
$(D)/python_mechanize: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_mechanize@
	@PREPARE_python_mechanize@
	cd @DIR_python_mechanize@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_mechanize@
	touch $@

#
# python_gdata
#
$(D)/python_gdata: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_gdata@
	@PREPARE_python_gdata@
	cd @DIR_python_gdata@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_gdata@
	touch $@

#
# python_zope_interface
#
$(D)/python_zope_interface: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_zope_interface@
	@PREPARE_python_zope_interface@
	cd @DIR_python_zope_interface@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_zope_interface@
	touch $@
