#!/usr/bin/env sh

BOX_URL="https://app.vagrantup.com/generic/boxes/ubuntu2004/versions/4.3.6/providers/virtualbox/amd64/vagrant.box"
BOX_DIR="./tmp/vagrant_box"
BOX_FILENAME="generic_ubuntu2004_4.3.6_virtualbox.box"
BOX_NAME="generic/ubuntu2004"
PROVIDER="virtualbox"
CHECKSUM="e71e30ad621625ff9586665e5beedda5080d9a1f1d8c24a3ca1537120bdcdb3b"

if [ ! -d "${BOX_DIR}" ]; then
  mkdir --parents --verbose "${BOX_DIR}"
fi

if [ ! -f "${BOX_DIR}/${BOX_FILENAME}" ]; then
  wget "${BOX_URL}" -O "${BOX_DIR}/${BOX_FILENAME}"
fi

vagrant box list

vagrant box add \
  --name "${BOX_NAME}" \
  --provider "${PROVIDER}" \
  --checksum-type sha256 \
  --checksum "${CHECKSUM}" \
    "${BOX_DIR}/${BOX_FILENAME}"


vagrant box list
