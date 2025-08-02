setenv bootargs "console=ttyS0,115200 root=/dev/ram rdinit=/bin/sh"
usb start
fatload usb 0:1 0x2000000 Image
fatload usb 0:1 0x2100000 rtd1295-zidoo-x9s.dtb
booti 0x2000000 - 0x2100000
  
