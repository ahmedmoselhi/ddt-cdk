# This file contains different cleaning targets. They try to be, at least
# in spirit, compatible with the GNU Makefiles standards.

# Note: automake defines targets clean etc, the Makefile author
# therefore should not. Instead, we define targets like clean-local,
# which are called from automake's clean.


# Delete all marker files in .deps, except those belonging to bootstrap,
# thus forcing unpack-patch-install-delete-targets to be rebuilt.
depsclean:
	$(DEPSCLEANUP)
	( cd .deps && find . ! -name "*\.*" -delete )

mostlyclean-local: cdk-clean

# Clean tuxbox source directories
cdk-clean:
	-$(MAKE) -C $(buildprefix)/$(KERNEL_DIR) clean
	-$(MAKE) -C $(driverdir) KERNEL_LOCATION=$(buildprefix)/$(KERNEL_DIR) \
		BIN_DEST=$(targetprefix)/bin \
		INSTALL_MOD_PATH=$(targetprefix) clean
	-$(MAKE) -C $(appsdir)/tools distclean
	-$(MAKE) -C $(appsdir)/libs/gst-plugins-dvbmediasink-* distclean
	-$(MAKE) -C $(appsdir)/libs/libstgles distclean
	-$(MAKE) -C $(TFINSTALLER_DIR) clean

# Clean tuxbox source directories. Clean up in cdkroot as much as the
# uninstall facilities of the components allow.
clean-local: mostlyclean-local depsclean
	-rm -rf $(hostprefix)
	-rm -rf $(crossprefix)
	-rm -rf $(prefix)/*cdkroot
	-rm -rf $(prefix)/*cdkroot-tftpboot
	-rm -rf $(prefix)/release*
	-rm -rf $(D)/linux-kernel*

# Be brutal...just nuke it!
distclean-local:
	-$(MAKE) -C $(appsdir) distclean
	-$(MAKE) -C $(appsdir)/tools distclean
	-$(MAKE) driver-clean
	-rm -f Makefile-archive
	-rm -f rules-downcheck.pl
	-rm -rf $(D)
	-rm -rf $(prefix)/*cdkroot/
	-rm -rf $(prefix)/*cdkroot-tftpboot
	-rm -rf $(crossprefix)
	-rm -rf $(hostprefix)
	-rm -rf $(serversupport)
	-rm -rf $(buildtmp)
	-rm -rf $(sourcedir)
	-@CLEANUP@

.PHONY: depsclean mostlyclean-local cdk-clean distclean-local list-clean
