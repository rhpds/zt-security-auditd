#!/bin/bash
USER=rhel

echo "Adding wheel" > /root/post-run.log
usermod -aG wheel rhel

echo "Setup vm rhel" > /tmp/progress.log

chmod 666 /tmp/progress.log

# Ensure audit package is installed and service is running
echo "Installing audit packages" >> /tmp/progress.log
dnf install -y audit audit-libs

echo "Starting auditd service" >> /tmp/progress.log
systemctl enable --now auditd

echo "Lab setup complete" >> /tmp/progress.log

# To fetch setup files from this lab's git repo at provision time, uncomment:
# TMPDIR=/tmp/lab-setup-$$
# git clone --single-branch --branch ${GIT_BRANCH:-main} --no-checkout \
#   --depth=1 --filter=tree:0 ${GIT_REPO} $TMPDIR
# git -C $TMPDIR sparse-checkout set --no-cone /setup-files
# git -C $TMPDIR checkout
# SETUP_FILES=$TMPDIR/setup-files
# ... cp $SETUP_FILES/your-file /destination ...
# rm -rf $TMPDIR
# Requires GIT_REPO and GIT_BRANCH in setup-automation/main.yml environment block.

#dnf install -y nc

# Epel
#dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
# certbot if needed
#dnf install -y certbot

# Enable cockpit functionality in showroom.
#dnf -y remove tlog cockpit-session-recording
#echo "[WebService]" > /etc/cockpit/cockpit.conf
#echo "Origins = https://cockpit-${GUID}.${DOMAIN}" >> /etc/cockpit/cockpit.conf
#echo "AllowUnencrypted = true" >> /etc/cockpit/cockpit.conf
#systemctl enable --now cockpit.socket
