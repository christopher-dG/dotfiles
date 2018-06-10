#!/usr/bin/env bash

# Arch Linux installation/configuration script.
# This must run on the installation media, with an internet connection.
# WARNING: This is untested. I take no responsibility for what happens.

set -e


### Generic utils ###

# Format some text to be noticable.
announce() {
    echo "========== $1 =========="
}

# Get some input from the user or let them exit.
promptgo() {
    echo "Press enter to begin, or ctrl-c to exit."
    echo  "Reminder: It's a good idea to run this script through tee."
    read
}

# Make sure that we have an internet connection.
checknet() {
    ping -c1 google.ca > /dev/null
}

# Run a bunch of preliminary steps.
prelim() {
    checknet
    [ -f ".vars" ] || (setvars && storevars)
    showvars
    warnvars
    promptgo
}


### Configuration variable get/put ###

# Prompt for configuration options.
setvars() {
    lsblk
    echo -n "Enter the disk to partition: "
    read -r disk

    echo -n "Enter your EFI partition (probably /dev/sda1): "
    read -r efi

    echo -n "Enter your SWAP partition (probably /dev/sda2): "
    read -r swap

    echo -n "Enter your root partition (probably /dev/sda3): "
    read -r root

    echo -n "Enter your hostname: "
    read -r host

    echo -n "Enter the root password: "
    read -r rootpasswd

    echo -n "Enter your username: "
    read -r user
    userhome="/home/$user"

    echo -n "Enter the user password: "
    read -r userpasswd
}

# Display the current configuration.
showvars() {
    source ".vars"
    echo -n "\
Configuration:

Disk:           $disk
EFI partition:  $efi
SWAP partition: $swap
Root partition: $root
Hostname:       $host
Root password:  $rootpasswd
Username:       $user
User password:  $userpasswd
User homedir:   $userhome
"
}

# Store the current configuration in a file.
storevars() {
    echo -n "\
export disk=$disk
export efi=$efi
export swap=$swap
export root=$root
export host=$host
export rootpasswd=$rootpasswd
export user=$user
export userpasswd=$userpasswd
export userhome=$userhome
" > .vars
}

warnvars() {
    echo "When you're finished with this script, remember to delete ./.vars"
}


### Install scripts ###

# Script to run while rooted on the installation media.
bs_prechroot() {
    source ".vars"

    timedatectl set-ntp true

    echo -n "\
Partition your disk. You probably want:
sda1: EFI System (1):        +512MiB
sda2: Linux SWAP (19):       +(RAM*2)GiB
sda3: Linux Filesystem (20)
"
    fdisk "$disk"
    mkfs.fat "$efi"
    mkswap "$swap"
    swapon "$swap"
    mkfs.ext4 "$root"
    mount "$root" /mnt
    mkdir /mnt/boot
    mount "$efi" /mnt/boot

    announce "Selecting mirrors, this will take a while..."
    pacman -Sy
    pacman -S --needed --noconfirm reflector
    mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    reflector -n5 -f5 | tee /etc/pacman.d/mirrorlist

    announce "Bootstrapping system packages, this will take a while..."
    pacstrap /mnt base base-devel

    genfstab -U /mnt >> /mnt/etc/fstab

    announce "Finished: run postchroot next."
}

# Script to run while chrooted.
bs_postchroot() {
    source ".vars"

    pacman -Syuu --noconfirm

    ln -sf /usr/share/zoneinfo/America/Winnipeg /etc/localtime
    hwclock --systohc
    sed -i "s/#en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf

    echo "$host" > /etc/hostname
    echo "root:$rootpasswd" | chpasswd

    pacman -S --needed --noconfirm intel-ucode
    bootctl --path=/boot install
    echo -n "\
default arch
editor  0
" > /boot/loader/loader.conf
    echo -n "\
title	Arch Linux
linux	/vmlinuz-linux
initrd	/intel-ucode.img
initrd  /initramfs-linux.img
options root=$root rw
" > /boot/loader/entries/arch.conf

    cp /etc/sudoers /etc/sudoers.bak
    sed -i "s/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers

    announce "Installing packages, this will take a while..."
    pacman -S --needed --noconfirm \
           acpi \
           acpid \
           aws-cli \
           bdf-unifont \
           compton \
           curl\
           dialog \
           dmenu \
           docker \
           dunst \
           emacs \
           expac \
           feh \
           git \
           htop \
           firefox \
           i3-gaps \
           i3lock \
           imagemagick \
           iw \
           openssh \
           mpv \
           neofetch \
           networkmanager \
           pulseaudio \
           pulsemixer \
           python \
           python-jedi \
           python-pip \
           python-pipenv \
           python-setuptools \
           redshift \
           rsync \
           rxvt-unicode \
           scrot \
           terminus-font \
           transmission-gtk \
           ttf-dejavu \
           ttf-freefont \
           ttf-inconsolata \
           unzip \
           wget \
           wmctrl \
           wpa_supplicant \
           xdotool \
           xf86-input-libinput \
           xf86-video-intel \
           xorg-xbacklight \
           xorg-server \
           xorg-xinit \
           xorg-xmodmap \
           yajl \
           zip \
           zsh

    useradd -G docker,input,wheel "$user"
    echo "$user:$userpasswd" | chpasswd
    chsh -s /bin/zsh "$user"

    systemctl enable acpid
    systemctl enable NetworkManager

    cd "$userhome"
    git clone https://github.com/christopher-dG/dotfiles .
    [ -d overlay ] && rsync -r overlay/ /
    [ -f README.md ] && git update-index --assume-unchanged README.md && rm -f README.md
    [ -f bootstrap.sh ] && git update-index --assume-unchanged bootstrap.sh && rm -f bootstrap.sh
    [ -d overlay ] && git update-index --assume-unchanged $(git ls-files overlay) && rm -rf overlay
    mkdir -p .local/bin code downloads
    git clone https://github.com/syl20bnr/spacemacs .emacs.d --branch develop
    git clone https://github.com/asdf-vm/asdf.git .asdf --branch v0.5.0
    chown -R "$user:$user" .
    cd -

    TODO: Install a different AUR tool.
    mkdir pacaur
    cd pacaur
    chown -R "$user:$user" .
    curl -o cower_PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
    curl -o pacaur_PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
    su "$user" -c "makepkg cower_PKGBUILD --skippgpcheck --install --needed --noconfirm"
    su "$user" -c "makepkg pacaur_PKGBUILD --install --needed --noconfirm"
    cd -
    rm -rf pacaur
    EDITOR=nano su "$user" -c "pacaur -S --needed --noconfirm --noedit hsetroot libinput-gestures"

    announce "Finished. Remember to delete .vars!"
}

### Entrypoint ###

case "$1" in
    "prechroot") prelim && bs_prechroot;;
    "postchroot") prelim && bs_postchroot;;
    *) echo "Usage: $0 prechroot | postchroot";;
esac
