DEVICE_PATH := device/benesse/41EA04

# Platform (Freescale i.MX6 SABRESD-derived BSP, Android 4.2.2, kernel 3.0.35)
TARGET_BOOTLOADER_BOARD_NAME := SABRESD
TARGET_BOARD_PLATFORM := imx6
TARGET_NO_BOOTLOADER := true

TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a9
TARGET_CPU_SMP := true
ARCH_ARM_HAVE_TLS_REGISTER := true

# Kernel: stock zImage, extracted from the unit's own boot.img (p1). The stock
# recovery.img (p2) carries a byte-identical kernel (md5
# 00440868d5f69dbf1f6ace85a991c52e) -- a ramdisk-only port, same as 40S404.
# NB: this is NOT the 40S404 kernel (f3b3de4f...); do not mix them.
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/zImage
BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 init=/init video=mxcfb0:dev=ldb,bpp=32 video=mxcfb1:off video=mxcfb2:off fbmem=10M fb0base=0x27b00000 vmalloc=400M androidboot.console=ttymxc0 androidboot.hardware=freescale androidboot.selinux=permissive
# kernel_addr=0x10808000 ramdisk_addr=0x11800000 tags_addr=0x10800100 page=2048
BOARD_KERNEL_BASE := 0x10800000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01000000 --tags_offset 0x00000100

# Partitions (live /proc/partitions, 2026-10-13): p1=boot p2=recovery
# p3=EXTENDED CONTAINER p4=data p5=system p6=cache p7=factory
BOARD_BOOTIMAGE_PARTITION_SIZE     := 8388608
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 8388608
BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 528482304
BOARD_USERDATAIMAGE_PARTITION_SIZE := 14631829504
BOARD_CACHEIMAGE_PARTITION_SIZE    := 528482304
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE  := ext4
BOARD_FLASH_BLOCK_SIZE := 131072
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_SUPPRESS_SECURE_ERASE := true
RECOVERY_SDCARD_ON_DATA := true

# 1024x768 panel (same as 40S404), same pwm-backlight (max_brightness 248)
DEVICE_RESOLUTION := 1024x768
TW_THEME := landscape_mdpi
TW_BRIGHTNESS_PATH := "/sys/class/backlight/pwm-backlight.0/brightness"
TW_MAX_BRIGHTNESS := 248
TW_DEFAULT_BRIGHTNESS := 200
TW_NO_SCREEN_BLANK := true
TW_NO_SCREEN_TIMEOUT := true

# Touch: this unit has a capacitive Novatek NT11003 (event1, multitouch),
# a Hanvon EM pen (event3) and the resistive rohm_bu21025 driver (event2)
# registered side by side -- unlike 40S404 (resistive only). Touch was
# accurate without any ABS range override on this unit, so none is set. If
# yours is offset, capture raw events (`dd if=/dev/input/event1 bs=16`, 32-bit
# input_event) while tapping the corners, then set TW_TOUCH_X/Y_MIN/MAX
# (needs patches/0001-minuitwrp-board-defined-touch-range.patch).

# 8MB recovery partition, ~3.86MB kernel => ~4.3MB for the gzip ramdisk.
TW_EXCLUDE_TWRPAPP := true
TW_EXCLUDE_SUPERSU := true
TW_EXCLUDE_BASH := true
TW_EXCLUDE_NANO := true
TW_EXCLUDE_TZDATA := true
TW_NO_EXFAT_FUSE := true
TW_EXCLUDE_MTP := true
