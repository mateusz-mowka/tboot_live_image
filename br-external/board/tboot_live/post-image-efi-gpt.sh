#!/bin/sh

set -e

BOARD_DIR=$(dirname "$0")

cd ${BINARIES_DIR}

# GPT partition type UUIDs
fat_type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7


# Partition UUIDs
efi_part_uuid=$(uuidgen)

# Boot partition offset and size, in 512-byte sectors
efi_part_start=64
efi_part_size=$(( 104857600 / 512 )) # 100MB

first_lba=34
last_lba=$(( efi_part_start + efi_part_size ))

# Disk image size in 512-byte sectors
image_size=$(( last_lba + first_lba ))

cp -f "$BOARD_DIR/grub.cfg" "efi-part/EFI/BOOT/grub.cfg"

git_tag=$(git describe --abbrev=0 --tags)
git_hash="$(git rev-parse HEAD)$(git diff-index --quiet HEAD -- || echo '!')"
build_date=$(date -u)
sed -i \
-e "s/__GIT_TAG__/$git_tag/g" \
-e "s/__GIT_HASH__/$git_hash/g" \
-e "s/__BUILD_DATE__/$build_date/g" \
"efi-part/EFI/BOOT/grub.cfg"

# Create EFI system partition
rm -f efi-part.vfat
dd if=/dev/zero of=efi-part.vfat bs=512 count=0 seek=$efi_part_size
mkdosfs -n LIVE efi-part.vfat
mcopy -bsp -i efi-part.vfat efi-part/startup.nsh ::startup.nsh
mcopy -bsp -i efi-part.vfat efi-part/EFI ::EFI
mcopy -bsp -i efi-part.vfat bzImage ::bzImage
mcopy -bsp -i efi-part.vfat rootfs.cpio.gz ::rootfs.cpio.gz
mcopy -bsp -i efi-part.vfat tboot.gz ::tboot.gz

rm -f disk.img
dd if=/dev/zero of=disk.img bs=512 count=0 seek=$image_size

sfdisk disk.img <<EOF
label: gpt
label-id: $(uuidgen)
device: /dev/foobar0
unit: sectors
first-lba: $first_lba
last-lba: $last_lba

/dev/foobar0p1 : start=$efi_part_start,  size=$efi_part_size,  type=$fat_type,   uuid=$efi_part_uuid,  name="efi-part.vfat"
EOF

dd if=efi-part.vfat of=disk.img bs=512 count=$efi_part_size seek=$efi_part_start conv=notrunc
