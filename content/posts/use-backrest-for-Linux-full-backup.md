+++
title = "Use backrest for Linux full backup"
date = "2024-10-02"
+++




### Needs
I am writing this post to record the effective method for establishing a automatic workflow that ensure my Linux desktop system is backed up correctly.

With no pain, and no mess things, totally use open-source software make this work seamlessly after configuring the process.


## Overview

1. Prepare for the entire process
2. Install backrest manually
3. Configure backrest through webui
4. Perform a full backup and attempt a restore for a reliability test
5. Make it happen seamlessly
6. Fix systemd-boot under LiveCD


## Before you go

**!WARNING!**

**The following operations are done in my [CachyOS](https://cachyos.org/) system, if you're using other Linux Distros, I can not promise that would work.But I think the whole process could be reproduced because of the idea: ["Everything is a file"](https://en.wikipedia.org/wiki/Everything_is_a_file)**




## Prepare

Take me as an example, I install my CachyOS in an 240GB NVME disk, and I use [systemd-boot](https://wiki.archlinux.org/title/Systemd-boot) rather than Grub as bootloader.Also, I set LUKS encryption for my root XFS disk volume.

I installed a 500GB hard disk drive on the motherboard and later erase it into XFS file system.This disk will be as the backup volume, also I mount it at `/run/media/admin/715335b3-bd5e-4ee4-8cde-c1298fe669df/` by KDE Device-Auto-Mount(715335b3-bd5e-4ee4-8cde-c1298fe669df is the UUID of the disk partition it can be found by `blkid` command ).

Notice: You can also make backup disk mount automatically by configure `/etc/fstab`, but I won't make a deep explanation here.

## Install backrest

There is an official [installation](https://github.com/garethgeorge/backrest?tab=readme-ov-file#installation) guide for installing backrest.

Here I write a few commands suitable for mostly Linux Distros to install it.

```
mkdir ~/Downloads

cd ~/Downloads

curl -L https://github.com/garethgeorge/backrest/releases/latest/download/backrest_Linux_x86_64.tar.gz -o ~/Downloads/backrest_Linux_x86_64.tar.gz

mkdir ~/Downloads/backrest_Linux_x86_64

tar -zxvf ~/Downloads/backrest_Linux_x86_64.tar.gz -C ~/Downloads/backrest_Linux_x86_64

sudo cp ~/Downloads/backrest_Linux_x86_64/backrest /usr/bin/backrest

rm -rf ~/Downloads/backrest_Linux_x86_64 && ~/Downloads/backrest_Linux_x86_64.tar.gz

```

Then input `backrest` in terminal to see if it works.

After that, create a `backrest.service` to manage backrest by systemd.

`/etc/systemd/system/backrest.service`

```
[Unit]
Description=Backrest Service
After=network.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/backrest
Environment="BACKREST_PORT=127.0.0.1:9898"

[Install]
WantedBy=multi-user.target

```

PS: Here I set `User=root` make sure backrest could read all files.

```
sudo systemctl daemon-reload
sudo systemctl enable backrest --now
sudo systemctl status backrest

```


## Configure backrest

Browse to your backrest webui at localhost:9898

Then you'll see a interface to let you create the admin role of backrest.

I just let [Disable Authentication] ✔️, but if your system isn't under NAT, you ought to create username and input a strong password.


#### Add Repo:

Click [+ Add Repo], here is my configuration:

![1](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/1.avif)

**Explanation:**
- [Repo Name] is doesn't matter what you set.
- [Repository URI] is the directory of the backup disk where you mount.(I set under /CachyOS to make the location of backup folder not at the root directory of this disk volume.)
- [Password] should be set by yourself,it is like the passphrase for encryption.



#### Add Plan:

After [Submit] the configuration of Restic Repository, you need to click [+ Add Plan]

![2](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/2.webp)


**Explanation:**
- [Plan Name] is doesn't matter what you set.
- [Repository] is just as [Repo Name]
- [Paths] should be set as root directory i.e. / (So it could do a full backup)
- [Excludes] are the directories should not be backed up.(At least set as the example)
- [Backup Schedule] as the example it will automatically do a backup every 4 hours.(You can change it by yourself.)
- [Clock for schedule] just recommand to set as [Last Run Time]
- [Backup Flags] add `--one-file-system` so /proc /tmp and so on won't be backuped.(More explanations here: [https://restic.readthedocs.io/en/latest/040_backup.html#excluding-files](https://restic.readthedocs.io/en/latest/040_backup.html#excluding-files)


#### Test:

![3](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/3.avif)

Click [Backup Now], wait the first long full backup process done.(Here I have backuped before, so just take a look the success result.)

![4](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/4.webp)

Since now, the part of  `Configure backrest` have done right, it'll automatically backup the whole system seamlessly in the background.

## Restore

Now, suppose your Linux system disk just explodes, only left your backup volume.

Luckily, you have a disaster recovery because of the automatically backup by backrest.

So let's go to the LiveCD of your Linux Distro(as for me it is CachyOS LiveCD) , and make your system restore like before.

---
#### First:

Install backrest in LiveCD

```
mkdir ~/Downloads

cd ~/Downloads

curl -L https://github.com/garethgeorge/backrest/releases/latest/download/backrest_Linux_x86_64.tar.gz -o ~/Downloads/backrest_Linux_x86_64.tar.gz

mkdir ~/Downloads/backrest_Linux_x86_64

tar -zxvf ~/Downloads/backrest_Linux_x86_64.tar.gz -C ~/Downloads/backrest_Linux_x86_64

sudo cp ~/Downloads/backrest_Linux_x86_64/backrest /usr/bin/backrest

rm -rf ~/Downloads/backrest_Linux_x86_64 && ~/Downloads/backrest_Linux_x86_64.tar.gz

```

Then change to the root user to get full file access.

```
sudo -i
or
su root
```

Then input `backrest` in terminal, but this time, do not close `backrest` in terminal, and also no need of systemd-service.

Just browse to your backrest webui localhost:9898

![5](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/5.avif)

Then you need to restore your configuration like before manually.

![6](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/6.webp)

![7](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/7.webp)


#### Second:

Erase a new disk for your new Linux system disk, here use Gparted for a quick work.

![8](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/8.webp)

![9](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/9.webp)

![10](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/10.webp)

Notice: You should add [boot] & [esp] Flag to the Fat32 EFI volume.Click [Manage Flags] to do this.

![11](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/11.webp)

![12](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/12.webp)

#### Third:

Mount the new Linux system disk partition and EFI partition.

```
sudo -i
mkdir /mnt/boot
mount /dev/sdc2 /mnt
mount /dev/sdc1 /mnt/boot

Notice: /dev/sdcX is define by your system environment, you can use command `lsblk` and `blkid` to see this.

```

Now you can execute restore command in backrest.

![13](https://static.yon.im/image/blog/use-backrest-for-Linux-full-backup/13.webp)

Notice: This process may take a lot of time, but you need to be patient.

#### Finally:

It's almost done, just need to fix bootloader.

```
genfstab -U /mnt > /mnt/etc/fstab

arch-chroot /mnt

bootctl install

paru -S linux-cachyos

Notice: `paru -S linux-cachyos` is works only in CachyOS(or other Arch Linux), if you're using other Linux Distro, you may needn't run this command.

mkinitcpio -P

```

Notice: /etc/crypttab should be reconfigured if your system once have LUKS crypt.

Now, you could reboot, and boot into the formal system before the accident happened.

### More About LUKS encryption

If you need LUKS encryption for root partition, you need to create a crypt root volume before you restore.However, due to space limitations, I won't go into more detail.


## Acknowledgements

- [https://github.com/restic/restic](https://github.com/restic/restic)
- [https://github.com/garethgeorge/backrest](https://github.com/garethgeorge/backrest)
