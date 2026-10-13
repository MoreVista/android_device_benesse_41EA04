# TWRP device tree: Benesse 41EA04 (i.MX6, sister of the 40S404)

Unofficial TWRP recovery for the Benesse tablet **41EA04** (Freescale/NXP i.MX6,
SABRESD-derived BSP, Android 4.2.2, kernel 3.0.35).

## Kernel

`BoardConfig.mk` expects `prebuilt/zImage`. This repository does not ship it. The unit's
`boot.img` and `recovery.img` carry the same kernel, so extract it from your own device:

```sh
# from a rooted Android shell on the tablet
adb shell su -c 'dd if=/dev/block/mmcblk0p1 of=/sdcard/boot.img bs=4096'
adb pull /sdcard/boot.img
python3 tools/extract_zimage.py boot.img prebuilt/zImage
```

Expected kernel for firmware `01.02.000` (built 2014-01-20): 3,861,856 bytes,
md5 `00440868d5f69dbf1f6ace85a991c52e`. **Do not use the 40S404 kernel**; they are different
builds. A different md5 means a different firmware build and is untested.

## Building

Tested with the TWRP minimal manifest `platform_manifest_twrp_omni`, branch `twrp-5.1`
(Android 5.1.1 base; `bootable/recovery` is TeamWin `android-9.0`, commit `90e5d95`),
inside an Ubuntu 14.04 userland with OpenJDK 7 and Python 2.

1. Sync the tree, then apply the patches from `patches/` inside `bootable/recovery`:
   ```sh
   cd bootable/recovery
   git apply /path/to/this/repo/patches/0002-partition-nullptr-to-NULL.patch
   ```
   - `0002` replaces one `nullptr` with `NULL` so the tree compiles with the old toolchain.
   - `0001-minuitwrp-board-defined-touch-range.patch` is **not needed** for this unit's
     touch. It is only used if you have to set `TW_TOUCH_X/Y_MIN/MAX` for an offset panel.
2. Put this repository at `device/benesse/41EA04` as a **real directory** (copy or bind mount).
   A symlink does not work: the product lookup does not follow it and falls through to a
   network fetch.
3. Add `prebuilt/zImage` (see above), then:
   ```sh
   source build/envsetup.sh
   lunch omni_41EA04-eng
   ALLOW_MISSING_DEPENDENCIES=true mka recoveryimage
   ```

The result is about 8.27 MB for an 8,388,608-byte partition (roughly 125 KB spare), so
adding features means removing something else.

## Flashing

Back up the current recovery first, then write only `mmcblk0p2`:

```sh
adb shell su -c 'dd if=/dev/block/mmcblk0p2 of=/sdcard/stock-recovery.img bs=4096'
adb pull /sdcard/stock-recovery.img
adb push recovery.img /sdcard/recovery.img
adb shell su -c 'dd if=/sdcard/recovery.img of=/dev/block/mmcblk0p2 bs=4096'
adb reboot recovery
```

Read the partition back and compare checksums before rebooting. If you ever rebuild with
changed mount points, boot the **new** recovery once (`adb reboot recovery`) before rebooting
to system, because an already-running old instance keeps its old `recovery.fstab`.

## Sources and licensing

- The kernel is GPLv2 and is **not** redistributed here. The kernel source corresponding to
  this unit's firmware has not been obtained (the 40S404 source archives are a different
  build). 
- TWRP is licensed by TeamWin; AOSP components under their own licenses. The patches here
  are against TeamWin's `bootable/recovery`.
- No stock firmware, recovery images or kernel binaries are included.
