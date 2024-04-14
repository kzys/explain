# Enable hibernation on Linux laptops

Basically following [Get hibernate working with LUKS](https://rdrn.me/ubuntu-hibernate-luks/) worked for me.

A few notes;

- `lvresize -l +20G --resizefs /dev/vgubuntu/swap_1` didn't work for me. `-l` is for % apparently.
- I have skipped "Use keyfile for LUKS".
- To make a bootable USB drive, follow [Create a bootable USB stick on Ubuntu](https://ubuntu.com/tutorials/create-a-usb-stick-on-ubuntu#1-overview).

## Framework Laptop specifics

- [Press F2](https://knowledgebase.frame.work/how-do-i-enter-the-bios-on-the-framework-laptop-HydmWf5Ad) to enter the BIOS setup.
  - Security > Secure Boot > Enforce Secure Boot > Disabled
- When the laptop is suspended, the power button's LED is "breathing" like old Apple laptops.
