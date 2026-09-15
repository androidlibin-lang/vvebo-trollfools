ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VVeboFix

VVeboFix_FILES = Tweak.x
VVeboFix_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/tweak.mk
