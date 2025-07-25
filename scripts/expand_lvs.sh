#!/bin/bash
set -euo pipefail

# Check if device exists and not already a PV
DEVICE="/dev/vdc"
VG_NAME="sysvg"

if ! lsblk "$DEVICE" &>/dev/null; then
  echo "Device $DEVICE not found. Aborting."
  exit 1
fi

if pvs "$DEVICE" &>/dev/null; then
  echo "$DEVICE is already a physical volume. Skipping pvcreate."
else
  echo "Creating physical volume on $DEVICE..."
  pvcreate "$DEVICE"
fi

# Extend the volume group
if ! vgs "$VG_NAME" | grep -q "$DEVICE"; then
  echo "Extending volume group $VG_NAME with $DEVICE..."
  vgextend "$VG_NAME" "$DEVICE"
else
  echo "$DEVICE already part of $VG_NAME. Skipping vgextend."
fi

# Allocate 120G each to /home and /var
lvextend -L +120G "/dev/$VG_NAME/lv_home" -r
lvextend -L +120G "/dev/$VG_NAME/lv_var" -r

# Calculate remaining space (~260G) and divide by 4
REMAINING_EXTENTS=$(vgs --noheadings --units g -o vg_free "$VG_NAME" | awk '{print int($1)}')
EACH_EXTENT=$((REMAINING_EXTENTS / 4))

echo "Allocating ~${EACH_EXTENT}G to each of the remaining LVs..."

for lv in lv_log lv_opt lv_audit lv_tmp; do
  lv_path="/dev/$VG_NAME/$lv"
  echo "Extending $lv_path by ${EACH_EXTENT}G..."
  lvextend -L +"${EACH_EXTENT}G" "$lv_path" -r
done

# Resize root with whatever remains
REMAINING_FINAL=$(vgs --noheadings --units g -o vg_free "$VG_NAME" | awk '{print int($1)}')
if [ "$REMAINING_FINAL" -gt 0 ]; then
  echo "Extending /dev/$VG_NAME/lv_root by ${REMAINING_FINAL}G..."
  lvextend -L +"${REMAINING_FINAL}G" "/dev/$VG_NAME/lv_root" -r
else
  echo "No free space left in VG for lv_root."
fi

echo "All volumes extended successfully."
