$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, vendor/omni/config/common.mk)

PRODUCT_COPY_FILES += \
    bionic/libc/zoneinfo/tzdata:recovery/root/system/usr/share/zoneinfo/tzdata

PRODUCT_DEVICE := 41EA04
PRODUCT_NAME := omni_41EA04
PRODUCT_BRAND := benesse
PRODUCT_MODEL := 41EA04
PRODUCT_MANUFACTURER := PANASONIC
PRODUCT_RELEASE_NAME := 41EA04

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.build.product=41EA04 \
    ro.product.device=41EA04
