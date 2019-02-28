#!/usr/bin/env bash

ping google.ca -W1 -c1 &> /dev/null
if [ $? -ne 0 ]; then
  echo "Connect to the internet first"
  exit 1
fi

if [ $1 != chroot ]; then
  timedatectl set-ntp true

  echo "Create partitions"
  fdisk /dev/sda

  echo -n "Boot partition number: "
  read boot
  mkfs.vfat -F32 /dev/sda$boot
  echo -n "SWAP partition number (empty for none): "
  read swap
  if [ ! -z $swap ]; then
    mkswap /dev/sda$swap
    swapon /dev/sda$swap
  fi
  echo -n "Root partition number: "
  read root
  mkfs.btrfs /dev/sda$root

  mount /dev/sda$root /mnt
  mkdir -p /mnt/boot
  mount /dev/sda$boot /mnt/boot

  pacstrap /mnt base base-devel

  genfstab -U /mnt >> /mnt/etc/fstab

  cp $0 /mnt/root/
  arch-chroot /mnt /root/$(basename $0) chroot

  rm /mnt/root/$(basename $0)
  umount /mnt/boot
  umount /mnt

  echo "Finished"
else
  ln -sf /usr/share/zoneinfo/America/Winnipeg /etc/localtime

  hwclock --systohc

  echo -n "System hostname: "
  read host

  sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
  locale-gen
  echo LANG=en_US.UTF-8 > /etc/locale.conf

  echo $host > /etc/hostname

  echo -n "Root password: "
  read rootpw
  echo root:$rootpw | chpasswd

  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg

  pacman -Sy
  pacman -Sy reflector
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
  echo "Sorting mirrors, this will take a while"
  reflector -n5 -f5 --save /etc/pacman.d/mirrorlist

  pacman -Syu
  pacman -Sy efibootmgr git grub intel-ucode zsh

  sed -i "s/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
  chsh -s /bin/zsh

  echo -n "Username: "
  read user
  useradd $user -G wheel -s /bin/zsh
  echo -n "User password: "
  read userpw
  echo $user:$userpw | chpasswd

  git clone https://github.com/christopher-dG/dotfiles /home/$user
  rsync -a /home/$user/overlay/ /
  chown $user:$user -R /home/$user

  curl -L -o yay.tar.gz https://github.com/Jguer/yay/releases/download/v9.1.0/yay_9.1.0_x86_64.tar.gz
  tar xf yay.tar.gz
  ./yay_9.1.0_x86_64/yay -S yay-bin
  rm -rf yay.tar.gz yay_9.1.0_x86_64

  yay -Sy --needed \
      alsa-utils \
      arandr \
      aws-cli \
      bat \
      baton-bin \
      bc \
      bdf-unifont \
      bluez \
      bluez-utils \
      clang \
      compton \
      curl \
      dmenu \
      docker \
      doctl-bin \
      dunst \
      elixir \
      emacs \
      entr \
      fd \
      feh \
      firefox \
      git-lfs \
      go \
      hsetroot \
      htop \
      hugo \
      i3-gaps \
      i3blocks \
      julia \
      libinput-gestures \
      lxappearance \
      mps-youtube \
      mpv \
      network-manager-applet \
      networkmanager \
      ntp \
      oomox \
      openssh \
      powertop \
      python \
      python-jedi \
      python-pywal \
      python-requests \
      ranger \
      redshift \
      ripgrep \
      rsync \
      rust-racer \
      rustup \
      rxvt-unicode \
      scrot \
      sd \
      source-highlight \
      spotifyd-bin \
      sqlite3 \
      terminus-font \
      thunar \
      tmux \
      ttf-dejavu \
      ttf-inconsolata \
      ttf-symbola \
      ufetch \
      unzip \
      virtualbox \
      virtualbox-guest-iso \
      wget \
      xdotool \
      xf86-input-libinput \
      xf86-video-intel \
      xorg-server \
      xorg-xbacklight \
      xorg-xinit \
      xorg-xprop \
      xorg-xrandr \
      xorg-xwininfo

  systemctl enable NetworkManager ntpd

  usermod degraafc -a -G docker,input,vboxusers

  sudo -u $user sh -c "
  git -C /home/$user remote set-url origin git@github.com:christopher-dG/dotfiles.git

  find /home/$user/overlay -type f | xargs git assume-unchanged
  git assume-unchanged /home/$user/installer.sh
  rm -rf /home/$user/{installer.sh,overlay}

  curl -L https://raw.github.com/zachcurry/emacs-anywhere/master/install | bash

  git clone https://github.com/asdf-vm/asdf.git /home/$user/.asdf --branch v0.6.3

  go get golang.org/x/tools/cmd/goimports
  go get github.com/stamblerre/gocode

  rustup install stable nightly
  rustup component add rust-src

  mkdir -p /home/$user/.ssh
  ssh-keygen -N"" -f /home/$user/.ssh/id_rsa

  systemctl --user enable emacs
  systemctl --user enable spotifyd
  "
fi
