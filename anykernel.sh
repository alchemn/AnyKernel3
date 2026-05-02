### AnyKernel install
# boot shell variables
block=boot;
is_slot_device=auto;
no_block_display=1;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
ui_print "- Rhodok Boot.img";
split_boot;
flash_boot;
ui_print "- boot.img sukses di rodhok!";

#dtbo Install
ui_print "- Rhodok Dtbo.img";
dtbo_block=$(find /dev/block/bootdevice/by-name/ -iname "dtbo*" | head -n 1);
if [ -n "$dtbo_block" ]; then
    dd if="$ZIPFILE/../dtbo.img" of="$dtbo_block" bs=4096;
    ui_print "- dtbo.img sukses di rodhok";
else
    ui_print "! dtbo partition not found, skipping...";
fi

## end boot install
