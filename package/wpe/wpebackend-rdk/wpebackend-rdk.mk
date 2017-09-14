################################################################################
#
# WPEBackend
#
################################################################################

WPEBACKEND_RDK_VERSION = bdcaf0018539927ee6d624622229f25979d415a2
WPEBACKEND_RDK_SITE = $(call github,WebPlatformForEmbedded,WPEBackend-rdk,$(WPEBACKEND_RDK_VERSION))
WPEBACKEND_RDK_INSTALL_STAGING = YES
WPEBACKEND_RDK_DEPENDENCIES = wpebackend libglib2

WPEBACKEND_RDK_FLAGS = 

ifeq ($(BR2_PACKAGE_LIBXKBCOMMON),y)
WPEBACKEND_RDK_DEPENDENCIES += libxkbcommon xkeyboard-config
else
WPEBACKEND_RDK_FLAGS += -DUSE_KEY_INPUT_HANDLING_LINUX_INPUT=ON
endif

ifeq ($(BR2_PACKAGE_GLUELOGIC_VIRTUAL_KEYBOARD),y)
WPEBACKEND_RDK_DEPENDENCIES += gluelogic 
WPEBACKEND_RDK_FLAGS += -DUSE_VIRTUAL_KEYBOARD=ON
endif

ifeq ($(BR2_PACKAGE_WPEFRAMEWORK_VIRTUALINPUT)$(BR2_PACKAGE_WPEFRAMEWORK_COMPOSITOR),yn)
WPEBACKEND_RDK_DEPENDENCIES += WPEFramework
WPEBACKEND_RDK_FLAGS += -DUSE_VIRTUAL_KEYBOARD=ON
endif

# USE_BACKEND_WESTEROS or USE_BACKEND_BCM_RPI
ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)

ifeq ($(BR2_PACKAGE_WAYLAND)$(BR2_PACKAGE_WESTEROS)$(BR2_PACKAGE_WPEFRAMEWORK_COMPOSITOR),yyn)
WPEBACKEND_RDK_DEPENDENCIES += wayland westeros libxkbcommon
WPEBACKEND_RDK_FLAGS +=-DUSE_BACKEND_WESTEROS=ON -DUSE_KEY_INPUT_HANDLING_LINUX_INPUT=OFF -DUSE_HOLE_PUNCH_GSTREAMER=OFF -DUSE_WESTEROS_SINK=OFF
else ifeq ($(BR2_PACKAGE_WAYLAND)$(BR2_PACKAGE_WPEFRAMEWORK_COMPOSITOR),yy)
WPEBACKEND_RDK_DEPENDENCIES += libegl wayland westeros
WPEBACKEND_RDK_FLAGS +=-DUSE_BACKEND_COMPOSITOR_CLIENT=ON -DUSE_KEY_INPUT_HANDLING_LINUX_INPUT=OFF -DUSE_HOLE_PUNCH_GSTREAMER=OFF -DUSE_WESTEROS_SINK=OFF
else
WPEBACKEND_RDK_DEPENDENCIES += libegl
WPEBACKEND_RDK_FLAGS += -DUSE_BACKEND_BCM_RPI=ON
endif

# USE_BACKEND_BCM_NEXUS_WAYLAND or USE_BACKEND_BCM_NEXUS
else ifeq ($(BR2_PACKAGE_HAS_NEXUS),y)

ifeq ($(BR2_PACKAGE_BCM_WESTON),y)
	WPEBACKEND_RDK_DEPENDENCIES += bcm-weston
	WPEBACKEND_RDK_FLAGS += -DUSE_BACKEND_BCM_NEXUS_WAYLAND=ON
else ifeq ($(BR2_PACKAGE_WAYLAND)$(BR2_PACKAGE_WESTEROS),yy)
	WPEBACKEND_RDK_DEPENDENCIES += wayland westeros libxkbcommon
	WPEBACKEND_RDK_FLAGS +=-DUSE_BACKEND_WESTEROS=ON -DUSE_KEY_INPUT_HANDLING_LINUX_INPUT=OFF -DUSE_HOLE_PUNCH_GSTREAMER=OFF -DUSE_WESTEROS_SINK=OFF
else
WPEBACKEND_RDK_FLAGS += -DUSE_BACKEND_BCM_NEXUS=ON
endif

# USE_BACKEND_WAYLAND_EGL
else ifeq ($(BR2_PACKAGE_KYLIN_GRAPHICS),y)
WPEBACKEND_RDK_FLAGS += -DUSE_BACKEND_WAYLAND_EGL=ON

# USE_BACKEND_INTEL_CE
else ifeq ($(BR2_PACKAGE_HORIZON_SDK)$(BR2_PACKAGE_INTELCE_SDK),y)
WPEBACKEND_RDK_FLAGS += -DUSE_BACKEND_INTEL_CE=ON

endif

WPEBACKEND_RDK_FLAGS += -DUSE_BACKEND_WAYLAND_EGL=ON \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -DMESA_EGL_NO_X11_HEADERS"

WPEBACKEND_RDK_CONF_OPTS = \
	$(WPEBACKEND_RDK_FLAGS)

$(eval $(cmake-package))