# TWRP device tree: Benesse 41EA04 (i.MX6, sister of the 40S404)

Unofficial TWRP recovery for the Benesse tablet **41EA04** (Freescale/NXP i.MX6,
SABRESD-derived BSP, Android 4.2.2, kernel 3.0.35).

**日本語:** ベネッセ 41EA04(40S404 の姉妹機種)用の非公式 TWRP デバイスツリーです。
純正 kernel を流用し、ramdisk だけを TWRP に差し替える方式です。**kernel などのバイナリは
このリポジトリに含まれません**(下記「Kernel」参照)。書き込みは自己責任で、必ず先に
純正 recovery をバックアップしてください。

> Not affiliated with Benesse, Panasonic or TeamWin. Provided as is, without warranty.
> Flashing a recovery can make a device unbootable.

## Status

Verified on one real unit (2026-10):

| Item | State |
|---|---|
| Boots into TWRP from the recovery partition | works |
| GUI, screen, brightness | works |
| Touch (capacitive) | works, no range override needed |
| `adb` in recovery | works |
| `/cache`, `/data` | mounted by TWRP at start-up |
| Reboot to Android from TWRP | works |
| EM pen (Hanvon), backup / restore, flashing zips, MTP | **not tested** (MTP is excluded to save space) |
| Behaviour after the screen-off timer | not checked (timeout is disabled in `BoardConfig.mk`) |

## Differences from the 40S404

| | 40S404 | 41EA04 |
|---|---|---|
| Firmware / kernel build | 02.05.000, 2018-03-14 | 01.02.000, 2014-01-20 |
| Kernel size / md5 | 3,854,680 B / `f3b3de4f…` | 3,861,856 B / `00440868…` |
| Logical partitions | system, cache, `/device` (1 GB), factory | system, cache, factory |
| Touch | resistive only, needs range override | capacitive Novatek + EM pen, no override |

## Partition layout

| Block device | Use |
|---|---|
| `mmcblk0p1` | boot (8 MB) |
| `mmcblk0p2` | recovery (8 MB) |
| `mmcblk0p3` | **MBR extended-partition container** (type 0x05, LBA 49152, 1040 MB) |
| `mmcblk0p4` | data |
| `mmcblk0p5` | system (ext4, 504 MB) |
| `mmcblk0p6` | cache (ext4, 504 MB) |
| `mmcblk0p7` | factory (ext4, 8 MB) |

## Do not map `/misc`

`mmcblk0p3` is **not** a misc partition; it is the extended-partition container that holds
p5-p7. TWRP clears the bootloader control block when rebooting to system, and if `/misc`
points at p3 that write zeroes the start of the container (its EBR chain). The kernel then
stops seeing the logical partitions and Android cannot boot. This happened on the sister
40S404 during development (the data survived and the table was rebuilt by hand). The stock
`recovery.fstab` has no `/misc` entry and neither does this one.

## Kernel (not included)

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
  build). Request it from Benesse if you need it.
- TWRP is licensed by TeamWin; AOSP components under their own licenses. The patches here
  are against TeamWin's `bootable/recovery`.
- No stock firmware, recovery images or kernel binaries are included.
