#!/usr/bin/env bash
set -euo pipefail

Red="\033[0;31m"
Bold="\033[1m"
Color_Off="\033[0m"
Cyan="\033[0;36m"
Green="\033[0;32m"

user_name="${SUDO_USER:-$USER}"
installer_search_path="/home/$user_name"

USAGE_MESSAGE="Usage: $0 [OPTIONS]... [DIRECTORY]...
Install Cisco Packet Tracer on openSUSE using .deb package.

  -d, --directory   ഡയറക്ടറി where installer is located
  -h, --help        Show this help message
  --uninstall       Remove Packet Tracer
"

install() {
    echo -e "${Green}${Bold}Searching for installers in $installer_search_path...${Color_Off}\n"

    mapfile -t installers < <(find "$installer_search_path" -type f \( -name "Cisco*Packet*.deb" -o -name "Packet*Tracer*.deb" \))

    if [ "${#installers[@]}" -eq 0 ]; then
        echo -e "${Red}${Bold}No Packet Tracer installer found.${Color_Off}"
        echo -e "Download from: ${Cyan}https://www.netacad.com/portal/resources/packet-tracer${Color_Off}"
        exit 1
    fi

    if [ "${#installers[@]}" -eq 1 ]; then
        selected_installer="${installers[0]}"
    else
        echo -e "${Cyan}${Bold}Multiple installers found:${Color_Off}"
        select installer in "${installers[@]}"; do
            selected_installer="$installer"
            break
        done
    fi

    echo -e "\n${Bold}Using:${Color_Off} $selected_installer\n"

    uninstall || true

    echo -e "${Green}Adding required repository (if missing)...${Color_Off}"
    if ! zypper lr | grep -q "fabio-harmony"; then
        sudo zypper ar -f https://download.opensuse.org/repositories/home:/fabio_s:/harmony/openSUSE_Leap_15.6/ fabio-harmony
    fi

    sudo zypper --gpg-auto-import-keys refresh

    echo -e "${Green}Installing dependencies...${Color_Off}"
    sudo zypper -n install \
        binutils \
        libqt5-qtbase-devel \
        libqt5-qtwebengine-devel \
        libqt5-qtmultimedia-devel \
        libqt5-qtnetworkauth-devel \
        libqt5-qtscript-devel \
        libqt5-qtspeech-devel \
        libqt5-qtsvg-devel \
        libqt5-qtwebchannel-devel \
        libqt5-qtwebsockets-devel \
        libfreetype6-2.14.2-lp156.240.1.x86_64

    workdir=$(mktemp -d)
    trap 'rm -rf "$workdir"' EXIT

    echo -e "${Green}Extracting package...${Color_Off}"
    ar -x "$selected_installer" --output="$workdir"
    tar -xf "$workdir/control.tar."* -C "$workdir"
    tar -xf "$workdir/data.tar."* -C "$workdir"

    echo -e "${Green}Installing files...${Color_Off}"
    sudo cp -r "$workdir/usr" /
    sudo cp -r "$workdir/opt" /

    if [ -f "$workdir/postinst" ]; then
        sed -i 's/sudo xdg-mime/sudo -u '"$user_name"' xdg-mime/' "$workdir/postinst"
        sed -i 's/gtk-update-icon-cache --force/gtk-update-icon-cache -t --force/' "$workdir/postinst"
        sudo bash "$workdir/postinst"
    fi

    sudo sed -i 's/packettracer/packettracer --no-sandbox/' /usr/share/applications/cisco-pt*.desktop || true

    echo -e "${Green}Setting up URL catcher (optional)...${Color_Off}"

    read -rp "Temporarily replace default browser to capture login URL? [y/N]: " yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        mkdir -p "/home/$user_name/.local/bin"
        mkdir -p "/home/$user_name/.local/share/applications"

        cat > "/home/$user_name/.local/bin/print-url-browser" <<EOF
#!/usr/bin/env bash
echo "=== Packet Tracer URL ==="
echo "\$1"
EOF

        chmod +x "/home/$user_name/.local/bin/print-url-browser"

        cat > "/home/$user_name/.local/share/applications/print-url-browser.desktop" <<EOF
[Desktop Entry]
Name=Print URL Browser
Exec=/home/$user_name/.local/bin/print-url-browser %u
Type=Application
MimeType=x-scheme-handler/http;x-scheme-handler/https;
Categories=Network;
EOF

        old_browser=$(xdg-settings get default-web-browser || true)
        xdg-settings set default-web-browser print-url-browser.desktop

        echo "Restore later with:"
        echo "xdg-settings set default-web-browser $old_browser"
    fi

    echo -e "\n${Green}${Bold}Installation complete.${Color_Off}"
    echo "Run: /opt/pt/packettracer"
}

uninstall() {
    if [ -d /opt/pt ]; then
        echo "Removing Packet Tracer..."
        sudo rm -rf /opt/pt
        sudo rm -f /usr/share/applications/cisco-pt*.desktop
        sudo update-mime-database /usr/share/mime || true
        sudo gtk-update-icon-cache -t --force /usr/share/icons/gnome || true
    fi
}

case "${1:-}" in
    -h|--help)
        echo "$USAGE_MESSAGE"
        ;;
    -d|--directory)
        installer_search_path="$2"
        install
        ;;
    --uninstall)
        uninstall
        ;;
    *)
        install
        ;;
esac
