#!/usr/bin/env bash
set -e

function init()
{
    # keyboard
    loadkeys fr

    # time
    timedatectl set-ntp true
    timedatectl set-timezone Europe/Paris
}

function partition()
{
    # partition
    OPTS_PARTED_UEFI="mklabel gpt mkpart ESP fat32 1MiB 512MiB mkpart root ext4 512MiB 100% set 1 esp on"
    DEVICE="/dev/$(lsblk --output NAME,TYPE --raw --noheadings | grep disk | cut -d ' ' -f1)"
    PARTITION_BOOT="${DEVICE}1"
    PARTITION_ROOT="${DEVICE}2"
    echo "Device found : $DEVICE"

    sgdisk --zap-all $DEVICE
    sgdisk -o $DEVICE
    wipefs -a -f $DEVICE
    partprobe -s $DEVICE
    parted -s $DEVICE $OPTS_PARTED_UEFI
    partprobe -s $DEVICE
    wipefs -a -f $PARTITION_BOOT
    wipefs -a -f $PARTITION_ROOT
    mkfs.fat -n ESP -F32 $PARTITION_BOOT
    mkfs.ext4 -L root $PARTITION_ROOT

    # mount filesystem
    mount --options "defaults,noatime" "$PARTITION_ROOT" /mnt
    mkdir /mnt/boot
    mount --options "defaults,noatime" "$PARTITION_BOOT" /mnt/boot

    # Efi System Partition
    ESP_DIR=/boot
    UUID_BOOT=$(blkid -s UUID -o value $PARTITION_BOOT)
    UUID_ROOT=$(blkid -s UUID -o value $PARTITION_ROOT)
    PARTUUID_BOOT=$(blkid -s PARTUUID -o value $PARTITION_BOOT)
    PARTUUID_ROOT=$(blkid -s PARTUUID -o value $PARTITION_ROOT)
}

function install()
{
    reflector --country US --latest 25 --age 24 --protocol https --completion-percent 100 --sort rate --save /etc/pacman.d/mirrorlist
    pacstrap /mnt base base-devel linux linux-firmware
}

function configuration()
{
    genfstab -U /mnt >> /mnt/etc/fstab
    # set timezone
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
    # run hwclock to generate /etc/adjtime
    arch-chroot /mnt hwclock --systohc
    # maybe set it directly in the file
    sed -i "/en_US.UTF8 UTF8/s/^#*//g" /etc/locale.gen
    sed -i "/en_US.UTF8 UTF8/s/^#*//g" /mnt/etc/locale.gen
    locale-gen
    arch-chroot /mnt locale_gen
    echo -e "KEYMAP=fr" > /mnt/etc/vconsole.conf
    echo "cell" > /mnt/etc/hostname
    # /etc/hosts should be here
    # set root passwd
    printf "root\nroot" | arch-chroot /mnt passwd
}

function grub()
{
    arch-chroot /mnt pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=grub_uefi --recheck
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}

function clean()
{
    umount -R /mnt/boot
    umount -R /mnt
    reboot
}

function main()
{
    init
    partition
    install
    configuration
    grub
    clean
}

main
