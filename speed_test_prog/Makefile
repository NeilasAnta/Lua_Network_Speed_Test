include $(TOPDIR)/rules.mk

PKG_NAME:=speed_test_prog
PKG_RELEASE:=1
PKG_VERSION:=1.0.0

include $(INCLUDE_DIR)/package.mk

define Package/speed_test_prog
	CATEGORY:=Base system
	TITLE:=speed_test_prog
endef

define Package/speed_test_prog/description
	This is a package that is used to do speedtest 
endef

define Build/Compile

endef

define Package/speed_test_prog/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/vuci-httpd/rpc
	$(INSTALL_BIN) ./files/speedtest.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/rpc/speed_test.lua $(1)/usr/lib/vuci-httpd/rpc/speedtest
endef

$(eval $(call BuildPackage,speed_test_prog))
