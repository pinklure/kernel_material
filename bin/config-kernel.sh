#!/bin/bash
# By PinkLure 2022.11.11

make clean
make ARCH=x86_64 defconfig
make ARCH=x86_64 kvm_guest.config

function enable() {
  echo "CONFIG_$1=y" >> .config
}

function disable() {
  echo "CONFIG_$1=n" >> .config
}

enable DEBUG_INFO
enable GDB_SCRIPTS
disable DEBUG_INFO_REDUCED
enable CONFIGFS_FS # CONFIGFS_FS and SECURITYFS is required for Debian Stretch
enable SECURITYFS
enable KASAN # KASAN* is memory bug detector
enable KASAN_INLINE
enable KCOV # KCOV is for coverage collection

make ARCH=x86_64 oldconfig



