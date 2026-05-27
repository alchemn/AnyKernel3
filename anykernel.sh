### AnyKernel install
block=boot;
is_slot_device=auto;
no_block_display=1;
. tools/ak3-core.sh;

ANDROID_VER=$(getprop ro.build.version.release)
SDK_VER=$(getprop ro.build.version.sdk)
DEVICE_MODEL=$(getprop ro.product.model)
DEVICE_CODENAME=$(getprop ro.product.device)
KERNEL_VER=$(uname -r)
CURRENT_SLOT=$(getprop ro.boot.slot_suffix)
BUILD_ID=$(getprop ro.build.id)


HYPEROS_VER=$(getprop ro.mi.os.version.incremental)
MIUI_VER=$(getprop ro.miui.ui.version.name)

ui_print "- Detecting ROM...";
if [ -n "$HYPEROS_VER" ]; then
    ui_print " ";
    ui_print "================================================";
    ui_print "  [!] HyperOS DETECTED - INSTALLATION ABORTED  ";
    ui_print "================================================";
    ui_print "  ROM      : HyperOS ($HYPEROS_VER)";
    ui_print "  Device   : $DEVICE_MODEL ($DEVICE_CODENAME)";
    ui_print " ";
    ui_print "  This kernel is built for AOSP-based ROMs only.";
    ui_print "  It is NOT compatible with HyperOS / MIUI.";
    ui_print "  Flashing on HyperOS may cause bootloop or";
    ui_print "  other critical issues.";
    ui_print " ";
    ui_print "  Use an AOSP ROM (e.g. LineageOS, PixelOS,";
    ui_print "  crDroid, Evolution X, etc.) before flashing.";
    ui_print "================================================";
    ui_print " ";
    exit 1;
fi

if [ -n "$MIUI_VER" ]; then
    ui_print " ";
    ui_print "================================================";
    ui_print "  [!] MIUI DETECTED - INSTALLATION ABORTED     ";
    ui_print "================================================";
    ui_print "  ROM      : MIUI ($MIUI_VER)";
    ui_print "  Device   : $DEVICE_MODEL ($DEVICE_CODENAME)";
    ui_print " ";
    ui_print "  This kernel is built for AOSP-based ROMs only.";
    ui_print "  It is NOT compatible with MIUI / HyperOS.";
    ui_print "================================================";
    ui_print " ";
    exit 1;
fi

ui_print "  ROM      : AOSP-based (safe to flash)";


ui_print "- Detecting device info...";
ui_print "  Device  : $DEVICE_MODEL ($DEVICE_CODENAME)";
ui_print "  Android : $ANDROID_VER (SDK $SDK_VER)";
ui_print "  Kernel  : $KERNEL_VER";
ui_print "  Slot    : ${CURRENT_SLOT:-single slot}";
ui_print "  Build   : $BUILD_ID";

ui_print "- Patching boot.img";
split_boot;
flash_boot;
ui_print "- boot.img patched!";

ui_print "- Patching dtbo.img";
dtbo_block=$(find /dev/block/bootdevice/by-name/ -iname "dtbo*" | head -n 1);
if [ -n "$dtbo_block" ]; then
    dd if="$ZIPFILE/../dtbo.img" of="$dtbo_block" bs=4096;
    ui_print "- dtbo.img patched!";
else
    ui_print "! dtbo partition not found, skipping...";
fi

ui_print " ";
ui_print "================================================";
ui_print "         RHODOK KERNEL - FLASH COMPLETE         ";
ui_print "================================================";
ui_print " ";
## end boot install
