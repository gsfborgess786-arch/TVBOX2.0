#!/bin/sh
# Uso: wifi-write.sh "SSID" "SENHA"   (SENHA vazia = rede aberta)
SSID="$1"; PSK="$2"
OUT=/etc/liveos/wpa.conf
mkdir -p /etc/liveos
{
	echo "ctrl_interface=/var/run/wpa_supplicant"
	echo "country=BR"
	if [ -n "$PSK" ]; then
		wpa_passphrase "$SSID" "$PSK" | grep -v '^[[:space:]]*#psk' || exit 1
	else
		printf 'network={\n\tssid="%s"\n\tkey_mgmt=NONE\n}\n' "$SSID"
	fi
} > "$OUT.tmp" 2>/dev/null || { rm -f "$OUT.tmp"; exit 1; }
grep -q 'network=' "$OUT.tmp" || { rm -f "$OUT.tmp"; exit 1; }
chmod 600 "$OUT.tmp"
mv "$OUT.tmp" "$OUT"
