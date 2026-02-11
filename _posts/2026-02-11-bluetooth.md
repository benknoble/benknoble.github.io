---
title: MT7925e Bluetooth woes
tags: [ linux ]
category: [ Blog ]
---

Some details on an error I had today and the seeming resolution.

I have a MediaTek Wireless device in my Framework desktop (outputs trimmed):

```shell
# lsusb
Bus 003 Device 003: ID 0e8d:0717 MediaTek Inc. Wireless_Device
# lshw
…
           *-network
                description: Ethernet interface
                product: MT7925 (RZ717) Wi-Fi 7 160MHz
                vendor: MEDIATEK Corp.
                physical id: 0
                bus info: pci@0000:c0:00.0
                logical name: wlan0
                version: 00
                serial: ac:f2:3c:34:dd:8b
                width: 64 bits
                clock: 33MHz
                capabilities: pciexpress msi pm bus_master cap_list ethernet physical
                configuration: broadcast=yes driver=mt7925e driverversion=6.12.63-gentoo-dist firmware=____000000-20260106153120 ip=192.168.2.248 latency=0 link=yes multicast=yes
                resources: irq:158 memory:b0600000-b07fffff memory:b0800000-b0807fff
…
                 *-usb:1
                      description: Bluetooth wireless interface
                      product: Wireless_Device
                      vendor: MediaTek Inc.
                      physical id: 3
                      bus info: usb@3:3
                      version: 1.00
                      serial: 000000000
                      capabilities: usb-2.10 bluetooth
                      configuration: driver=btusb maxpower=100mA speed=480Mbit/s
```

(The Bluetooth wireless interface is on a different pci slot from the Ethernet
interface according to `lshw`, but I think it's physically part of the same
stuff?)

```shell
# hwinfo

63: PCI c000.0: 0280 Network controller
  [Created at pci.386]
  Unique ID: y9sn.W5ZKz6Jz0dA
  Parent ID: aYFK.ZyxDeoKNER1
  SysFS ID: /devices/pci0000:00/0000:00:02.3/0000:c0:00.0
  SysFS BusID: 0000:c0:00.0
  Hardware Class: network
  Model: "MEDIATEK Network controller"
  Vendor: pci 0x14c3 "MEDIATEK Corp."
  Device: pci 0x0717 
  SubVendor: pci 0x14c3 "MEDIATEK Corp."
  SubDevice: pci 0x0717 
  Driver: "mt7925e"
  Driver Modules: "mt7925e"
  Device File: wlan0
  Memory Range: 0xb0600000-0xb07fffff (rw,non-prefetchable)
  Memory Range: 0xb0800000-0xb0807fff (rw,non-prefetchable)
  IRQ: 158 (9607 events)
  HW Address: ac:f2:3c:34:dd:8b
  Permanent HW Address: ac:f2:3c:34:dd:8b
  Link detected: yes
  Module Alias: "pci:v000014C3d00000717sv000014C3sd00000717bc02sc80i00"
  Driver Info #0:
    Driver Status: mt7925e is active
    Driver Activation Cmd: "modprobe mt7925e"
  Config Status: cfg=new, avail=yes, need=no, active=unknown
  Attached to: #51 (PCI bridge)

88: USB 00.0: 0000 Unclassified device
  [Created at usb.122]
  Unique ID: CiZ2.dgyAFLvpDoA
  Parent ID: uIhY.5sqDI7PdmUC
  SysFS ID: /devices/pci0000:00/0000:00:08.3/0000:c5:00.0/usb3/3-3/3-3:1.0
  SysFS BusID: 3-3:1.0
  Hardware Class: unknown
  Model: "MediaTek Wireless_Device"
  Hotplug: USB
  Vendor: usb 0x0e8d "MediaTek Inc."
  Device: usb 0x0717 "Wireless_Device"
  Revision: "1.00"
  Serial ID: "000000000"
  Driver: "btusb"
  Driver Modules: "btusb"
  Speed: 480 Mbps
  Module Alias: "usb:v0E8Dp0717d0100dcEFdsc02dp01icE0isc01ip01in00"
  Driver Info #0:
    Driver Status: btusb is active
    Driver Activation Cmd: "modprobe btusb"
  Config Status: cfg=new, avail=yes, need=no, active=unknown
  Attached to: #94 (Hub)
```

Anyway, after a reboot today, I saw the following issues

- Bluetooth wasn't on or working, including no mouse connection (fortunately I
  have mouse keys on my ErgoDox EZ)
- The kernel had some interesting logs:

```
Feb 11 10:45:16 merguez kernel: Bluetooth: hci0: Execution of wmt command timed out
Feb 11 10:45:16 merguez kernel: Bluetooth: hci0: Failed to send wmt func ctrl (-110)
Feb 11 10:45:16 merguez kernel: Bluetooth: hci0: HCI Enhanced Setup Synchronous Connection command is advertised, but not supported.
```

Things got even weirder as I started poking the hardware with various tools like
`inxi`, `lsusb -v`, and `hw-probe`, although that might also have been due to
removing the kernel modules and re-adding them. In particular, reloading `btusb`
did practically nothing; reloading `mt7925e` and `btusb` seemed to crash
Bluetooth altogether (although WiFi came back with the `mt7925e` driver, so it
was just the 2nd load of `btusb` that failed).

I was able to confirm via `last` that I had booted my current kernel at least
once prior to today, so I was pretty sure that wasn't the issue (but I have
several old kernels laying around just in case):

```
λ ll /boot/vmlinuz-6.12.*
-rw-r--r-- 1 root root 20439552 13 oct.  21:25 /boot/vmlinuz-6.12.47-gentoo-dist
-rw-r--r-- 1 root root 20488704 13 oct.  15:35 /boot/vmlinuz-6.12.47-gentoo-dist.old
-rw-r--r-- 1 root root 20451840  7 nov.  09:20 /boot/vmlinuz-6.12.54-gentoo-dist
-rw-r--r-- 1 root root 20460032  1 déc.  16:49 /boot/vmlinuz-6.12.58-gentoo-dist
-rw-r--r-- 1 root root 20619776 29 janv. 17:09 /boot/vmlinuz-6.12.63-gentoo-dist
-rw-r--r-- 1 root root 20619776 13 janv. 08:42 /boot/vmlinuz-6.12.63-gentoo-dist.old
```

## Solution

Turns out, [the Mint folks were
right](https://forums.linuxmint.com/viewtopic.php?t=461458): I powered down
completely, left the system unplugged for a while, and then booted on with no
issues.

Now the kernel logs look much nicer:

```
Feb 11 14:03:30 merguez kernel: Bluetooth: hci0: Device setup in 1738015 usecs
Feb 11 14:03:30 merguez kernel: Bluetooth: hci0: HCI Enhanced Setup Synchronous Connection command is advertised, but not supported.
Feb 11 14:03:31 merguez kernel: Bluetooth: hci0: AOSP extensions version v1.00
Feb 11 14:03:31 merguez kernel: Bluetooth: hci0: AOSP quality report is supported
Feb 11 14:03:31 merguez kernel: Bluetooth: BNEP (Ethernet Emulation) ver 1.3
Feb 11 14:03:31 merguez kernel: Bluetooth: BNEP filters: protocol multicast
Feb 11 14:03:31 merguez kernel: Bluetooth: BNEP socket layer initialized
Feb 11 14:03:31 merguez kernel: Bluetooth: MGMT ver 1.23
Feb 11 14:03:46 merguez kernel: Bluetooth: RFCOMM TTY layer initialized
Feb 11 14:03:46 merguez kernel: Bluetooth: RFCOMM socket layer initialized
Feb 11 14:03:46 merguez kernel: Bluetooth: RFCOMM ver 1.11
Feb 11 14:03:55 merguez kernel: magicmouse 0005:004C:0265.0005: unknown main item tag 0x0
Feb 11 14:03:55 merguez kernel: input: Apple Inc. Magic Trackpad 2 as /devices/virtual/misc/uhid/0005:004C:0265.0005/input/input15
Feb 11 14:03:55 merguez kernel: magicmouse 0005:004C:0265.0005: input,hidraw4: BLUETOOTH HID v3.11 Mouse [Slate] on ac:f2:3c:34:dd:8c
```

## Kernel devices

Of note, the `drivers/bluetooth/btusb.c` doesn't list `0e8d:0717` in the
MediaTek devices, although there is what looks to my extremely untrained eyes
like some kind of generic fallback device:

```c
	/* MediaTek Bluetooth devices */
	{ USB_VENDOR_AND_INTERFACE_INFO(0x0e8d, 0xe0, 0x01, 0x01),
	  .driver_info = BTUSB_MEDIATEK |
			 BTUSB_WIDEBAND_SPEECH },
```

(The docs for `USB_VENDOR_AND_INTERFACE` don't mean much to me:)

```c
/**
 * USB_VENDOR_AND_INTERFACE_INFO - describe a specific usb vendor with a class of usb interfaces
 * @vend: the 16 bit USB Vendor ID
 * @cl: bInterfaceClass value
 * @sc: bInterfaceSubClass value
 * @pr: bInterfaceProtocol value
 *
 * This macro is used to create a struct usb_device_id that matches a
 * specific vendor with a specific class of interfaces.
 *
 * This is especially useful when explicitly matching devices that have
 * vendor specific bDeviceClass values, but standards-compliant interfaces.
 */
#define USB_VENDOR_AND_INTERFACE_INFO(vend, cl, sc, pr) \
	.match_flags = USB_DEVICE_ID_MATCH_INT_INFO \
		| USB_DEVICE_ID_MATCH_VENDOR, \
	.idVendor = (vend), \
	.bInterfaceClass = (cl), \
	.bInterfaceSubClass = (sc), \
	.bInterfaceProtocol = (pr)
```

For the network controller, we have `PCI_VENDOR_ID_MEDIATEK=0x14c3` via
`include/linux/pci_ids.h` and then

```c
static const struct pci_device_id mt7925_pci_device_table[] = {
	{ PCI_DEVICE(PCI_VENDOR_ID_MEDIATEK, 0x7925),
		.driver_data = (kernel_ulong_t)MT7925_FIRMWARE_WM },
	{ PCI_DEVICE(PCI_VENDOR_ID_MEDIATEK, 0x0717),
		.driver_data = (kernel_ulong_t)MT7925_FIRMWARE_WM },
	{ },
};
```

in the `drivers/net/wireless/mediatek/mt76/mt7925` tree.

## Other fora

Places I looked for help via Ecosia searches of the kernel logs and model IDs:

- [Fedora forum](https://discussion.fedoraproject.org/t/bluetooth-mt7925e-doesnt-work-anymore-after-an-update-on-fedora-workstation-42/164707)
- [Framework forum](https://community.frame.work/t/bluetooth-adapter-detected-but-unable-to-initialize-firmware/55427/3)
- Various Arch fora

Seems like there are lots of MediaTek driver issues, but none were _exactly_
like mine except that Mint forum.
