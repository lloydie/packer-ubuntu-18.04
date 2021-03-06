#!/bin/bash -eu

# Reduce installed languages to just "en_US"
echo "==> Configuring locales"
apt-get -y purge language-pack-en language-pack-gnome-en
sed -i '/^[^# ]/s/^/# /' /etc/locale.gen
LANG=en_US.UTF-8
LC_ALL=$LANG
locale-gen --purge $LANG
update-locale LANG=$LANG LC_ALL=$LC_ALL

# Remove some packages to get a minimal install
echo "==> Removing all linux kernels except the currrent one"
dpkg --list 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs apt-get -y purge
echo "==> Removing linux source"
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge
echo "==> Removing documentation"
dpkg --list | awk '{ print $2 }' | grep -- '-doc$' | xargs apt-get -y purge
echo "==> Removing X11 libraries"
apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6 libxau6 libxdmcp6
echo "==> Removing other oddities"
apt-get -y purge popularity-contest installation-report plymouth xdg-user-dirs language-selector-common
apt-get -y purge nano

# Clean up orphaned packages with deborphan
apt-get -y install deborphan
deborphan --find-config | xargs apt-get -y purge
while [ -n "$(deborphan --guess-all)" ]; do
    deborphan --guess-all | xargs apt-get -y purge
done
apt-get -y purge deborphan dialog

# Clean up the apt cache
apt-get -y autoremove --purge
apt-get -y clean

echo "==> Removing APT files"
find /var/lib/apt -type f -exec rm -rf {} \;
echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;
