2020-08-15, edX ThinkPad X1 Carbon, Xubuntu 20.04
(root partition encrypted with LUKS, but not boot partition)
(dual booted w/ Windows)

Around 2020-07, while trying to get customizations in /etc/default/grub to
manifest on startup, GRUB2 stopped being able to boot on its own, and would
just drop me at a 'grub>' prompt, which I'd have to fix by doing one of:

```
linux (hd0,gpt2)/boot/vmlinuz root=/dev/mapper/crypt1.vg1-crypt1.vg1.lvroot
initrd (hd0,gpt2)/boot/initrd.img
boot
```

or, as I found out just today:
```
configfile (hd0,gpt2)/grub/grub.cfg
```

The problem seems to be that /boot/efi/EFI/ubuntu/grub.cfg has
the following contents:
```
search.fs_uuid 7fcd530e-e59e-4b9e-8347-c2ae58d27fb9 root lvmid/F1GFve-sbwa-rg1p-gifr-pzlB-15Yo-v29DJ3/vi33Dw-Xhkk-iODF-Biek-ZvaW-4fww-SeOT6e 
set prefix=($root)'/boot/grub'
configfile $prefix/grub.cfg
```
I believe that the problem is that the 7fcd... UUID there refers to the
root partition, which is encrypted, and is also not where /boot will be
found. I'm not sure how it got in this state.
`grub-install /dev/nvme0n1p2` seems to just recreate this same file.

However, manually replacing it with this fixed the 'grub>' prompt issue:
```
configfile (hd0,gpt2)/grub/grub.cfg
```

I still face the problem, though, that customizations to /etc/default/grub
do not manifest.
