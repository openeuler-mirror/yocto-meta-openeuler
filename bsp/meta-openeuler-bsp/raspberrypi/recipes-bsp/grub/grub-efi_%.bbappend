EFI_PROVIDER = "grub-efi"

# we need more buildin grub
GRUB_BUILDIN = "acpi all_video archelp bfs bitmap bitmap_scale blocklist boot bufio cat cbfs chain cmp configfile cpio crc64 crypto cryptodisk date datehook datetime disk diskfilter div dm_nv echo efi_gop efinet elf eval exfat ext2 extcmd fat fdt file font fshelp geli gettext gfxmenu gfxterm gfxterm_background gfxterm_menu gptsync gzio halt hashsum hello help hexdump http iso9660 jfs jpeg keystatus ldm linux loadenv loopback ls lsacpi lsefi lsefimmap lsefisystab lsmmap lssal luks lvm lzopio macbless macho  memdisk memrw minicmd minix minix2 minix3  mmap mpi msdospart net newc normal ntfs ntfscomp odc offsetio part_acorn part_amiga part_apple part_bsd part_dfly part_dvh part_gpt part_msdos part_plan part_sun part_sunpc parttool png priority_queue probe procfs progress raid5rec raid6rec read reboot regexp reiserfs romfs scsi search search_fs_file search_fs_uuid search_label serial setjmp sfs sleep squash4 tar terminal terminfo tftp tga time tr trig true udf ufs1 ufs1_be ufs2 video video_colors video_fb videoinfo xen_boot xfs xnu_uuid xzio zfs zfscrypt zfsinfo"

do_deploy:append () {
    install -d ${DEPLOYDIR}/EFI/BOOT
    install -m 644 ${D}${EFI_FILES_PATH}/${GRUB_IMAGE} ${DEPLOYDIR}/EFI/BOOT
}

do_deploy[dirs] += "${DEPLOYDIR}/EFI/BOOT"
