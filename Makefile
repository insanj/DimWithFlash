THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang
ARCHS = armv7 arm64

TWEAK_NAME = DimWithFlash
DimWithFlash_FILES = Tweak.xm
DimWithFlash_FRAMEWORKS = UIKit AVFoundation

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

internal-after-install::
	install.exec "killall -9 backboardd"