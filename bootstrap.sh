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
    readvars || (setvars && storevars)
    showvars
    warnvars
    promptgo
}


### Configuration variable get/put ###

# Read a configuration from a file if it exists.
readvars() {
    if [ -f ".vars" ]; then
        source ".vars"
        return 0
    else
        return 1
    fi
}

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
    echo -n "\"
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
    pacman -S --needed --noconfirm reflector
    mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    reflector -n5 -f5 | tee /etc/pacman.d/mirrorlist

    announce "Bootstrapping system packages, this will take a while..."
    pacstrap /mnt base base-devel

    genfstab -U /mnt >> /mnt/etc/fstab

    announce "Finished."
    echo "Run postchroot next"
}

# Script to run while chrooted.
bs_postchroot() {
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
           zsh

    useradd -G docker,input,wheel "$user"
    echo "$user:$userpasswd" | chpasswd
    chsh -s /bin/zsh "$user"

    systemctl enable acpid
    systemctl enable NetworkManager

    git clone "https://github.com/christopher-dG/dotfiles" "$userhome"
    rsync -r overlay/ /
    [ -f "$userhome/README.md" ] && git -C "$userhome" git update-index --assume-unchanged "$userhome/README.md" && rm -f "$userhome/README.md"
    [ -f "$userhome/bootstrap.sh" ] && git -C "$userhome" git update-index --assume-unchanged "$userhome/bootstrap.sh" && rm -f "$userhome/bootstrap.sh"
    [ -d "$userhome/overlay" ] && git -C "$userhome" git update-index --assume-unchanged "$userhome/overlay" && rm -rf "$userhome/overlay"
    mkdir -p "$userhome/.local/bin" "$userhome/downloads" "$userhome/code"
    chown -R "$user:$user" "$userhome"


    git clone "https://github.com/syl20bnr/spacemacs" "$userhome/.emacs.d" --branch develop

    git clone "https://github.com/asdf-vm/asdf.git" "$userhome/.asdf" --branch v0.5.0
    source "$userhome/.asdf/asdf.sh"
    plugins=(elixir erlang golang julia nodejs postgres python ruby rust)
    for plugin in "${plugins[@]}"; do
        asdf plugin-add "$plugin"  # Add plugins but don't install any versions.
    done

    # TODO: Install a different AUR tool.
    mkdir pacaur
    cd pacaur
    curl -o PKGBUILD "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower"
    su "$user" -c "makepkg PKGBUILD --skippgpcheck --install --needed --noconfirm"
    curl -o PKGBUILD "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur"
    su "$user" -c "makepkg PKGBUILD --install --needed --noconfirm"
    rm -rf pacaur
    su "$user" -c "pacaur -S --needed --noconfirm hsetroot libinput-gestures"

    announce "Finished"
}

### Entrypoint ###

case "$1" in
    "prechroot") prelim && bs_prechroot;;
    "postchroot") prelim && bs_postchroot;;
    *) echo "Usage: $0 prechroot | postchroot";;
esac
