### AnyKernel install
block=boot;
is_slot_device=auto;
no_block_display=1;

. tools/ak3-core.sh;

LOG_DIR="/sdcard/kernel_logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_PREFIX="$LOG_DIR/$TIMESTAMP"

mkdir -p "$LOG_DIR"

ANDROID_VER=$(getprop ro.build.version.release)
SDK_VER=$(getprop ro.build.version.sdk)
DEVICE_MODEL=$(getprop ro.product.model)
DEVICE_CODENAME=$(getprop ro.product.device)
KERNEL_VER=$(uname -r)
CURRENT_SLOT=$(getprop ro.boot.slot_suffix)
BUILD_ID=$(getprop ro.build.id)
FINGERPRINT=$(getprop ro.build.fingerprint)

ui_print "- Detecting device info...";
ui_print "  Device  : $DEVICE_MODEL ($DEVICE_CODENAME)";
ui_print "  Android : $ANDROID_VER (SDK $SDK_VER)";
ui_print "  Kernel  : $KERNEL_VER";
ui_print "  Slot    : ${CURRENT_SLOT:-single slot}";
ui_print "  Build   : $BUILD_ID";

ui_print "- Saving pre-flash log...";

{
  echo "===== RHODOK KERNEL FLASHER ====="
  echo "Timestamp  : $TIMESTAMP"
  echo "Device     : $DEVICE_MODEL ($DEVICE_CODENAME)"
  echo "Android    : $ANDROID_VER (SDK $SDK_VER)"
  echo "Old kernel : $KERNEL_VER"
  echo "Slot       : ${CURRENT_SLOT:-single slot}"
  echo "Build ID   : $BUILD_ID"
  echo "Fingerprint: $FINGERPRINT"
  echo ""
  echo "===== DMESG ====="
  dmesg 2>/dev/null || echo "(unavailable)"
  echo ""
  echo "===== LOGCAT (last 200 lines) ====="
  logcat -d -t 200 2>/dev/null || echo "(unavailable)"
} > "$LOG_PREFIX-pre_flash.txt" 2>&1

ui_print "  Saved: $LOG_PREFIX-pre_flash.txt";

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

cat > "$LOG_DIR/grab_postboot_log.sh" << POSTSCRIPT
#!/system/bin/sh
LOG="${LOG_PREFIX}-post_boot.txt"
{
  echo "===== RHODOK POST-BOOT LOG ====="
  echo "Timestamp  : \$(date +"%Y%m%d_%H%M%S")"
  echo "New kernel : \$(uname -r)"
  echo "Uptime     : \$(cat /proc/uptime)"
  echo ""
  echo "===== DMESG ====="
  dmesg 2>/dev/null || echo "(unavailable)"
  echo ""
  echo "===== LOGCAT (last 300 lines) ====="
  logcat -d -t 300 2>/dev/null || echo "(unavailable)"
  echo ""
  echo "===== PSTORE ====="
  cat /sys/fs/pstore/console-ramoops-0 2>/dev/null \
    || cat /proc/last_kmsg 2>/dev/null \
    || echo "(unavailable)"
} > "\$LOG" 2>&1
echo "Done: \$LOG"
POSTSCRIPT

chmod 755 "$LOG_DIR/grab_postboot_log.sh"

ui_print " ";
ui_print "================================================";
ui_print "  Logs saved to: /sdcard/kernel_logs/";
ui_print "  Pre-flash: ${TIMESTAMP}-pre_flash.txt";
ui_print "================================================";
ui_print "  If boot succeeds, run on PC:";
ui_print "  adb shell sh /sdcard/kernel_logs/grab_postboot_log.sh";
ui_print "  adb pull /sdcard/kernel_logs/ ./kernel_logs/";
ui_print "================================================";
ui_print "  If bootloop, pre-flash log is already there.";
ui_print "  Pull from recovery:";
ui_print "  adb pull /sdcard/kernel_logs/ ./kernel_logs/";
ui_print "================================================";
ui_print " ";

## end boot install
