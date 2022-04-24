#!/bin/bash
#
#

set -ex

RELEASE="unknown"
if [ -f /etc/lsb-release ]; then
	DISTRIB_ID=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -d= -f2)
	if [ -n "${DISTRIB_ID}" ]; then
		case "${DISTRIB_ID}" in
			Ubuntu)
				RELEASE=ubuntu
				;;
		esac
	fi
fi

SKU_NUMBER=$(sudo dmidecode -s system-sku-number)
git clone https://github.com/osfordev/hardware.git /tmp/hardware
mkdir "/tmp/hardware/${SKU_NUMBER}"
cd "/tmp/hardware/${SKU_NUMBER}"
sudo aplay -l > "${SKU_NUMBER}.aplay-l.${RELEASE}"
sudo dmesg > "${SKU_NUMBER}.dmesg.${RELEASE}"
sudo hwinfo > "${SKU_NUMBER}.hwinfo.${RELEASE}"
sudo i2cdetect -l > "${SKU_NUMBER}.i2cdetect-l.${RELEASE}"
sudo lshw > "${SKU_NUMBER}.lshw.${RELEASE}"
sudo lsmod > "${SKU_NUMBER}.lsmod.${RELEASE}"
sudo lspci -knn > "${SKU_NUMBER}.lspci-knn.${RELEASE}"
sudo lsusb -vt > "${SKU_NUMBER}.lsusb-vt.${RELEASE}"
DISPLAY=:0 xinput > "${SKU_NUMBER}.xinput.${RELEASE}"
for CODEC in /proc/asound/card[0-9]/codec#[0-9]; do
	HARDWARE_FILE=$(echo "${CODEC}" | sed 's~/~-~g')
	cat "${CODEC}" > "${SKU_NUMBER}.cat${HARDWARE_FILE}.${RELEASE}"
done

git add -A
git commit -m "Add ${SKU_NUMBER}"
git push
