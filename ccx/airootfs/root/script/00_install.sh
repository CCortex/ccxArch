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
}

function main()
{
    init
    partition
}

main
