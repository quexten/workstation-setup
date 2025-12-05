#!/bin/bash

ensure_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit
    fi
}

install_toolchains() {
    echo "Installing toolchains..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    dnf install nodejs npm -y
}

install_dev_tools() {
    echo "Installing development tools..."
    dnf install fish -y
    chsh -s /usr/bin/fish
    cargo install --locked zellij
    dnf install git gcc clang cmake gdb -y
    dnf install vim neovim -y
    dnf install docker docker-compose -y
    systemctl start docker
    systemctl enable docker
    curl -fsSL https://tailscale.com/install.sh | sh
    dnf install flatpak-builder -y
    dnf install dnf5-plugins -y
    dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
    dnf install gh --repo gh-cli -y
}

configure_fish() {
    echo "Configuring fish shell..."
    mkdir -p ~/.config/fish
    cat > ~/.config/fish/config.fish << 'EOF'
if status is-interactive
    # Commands to run in interactive sessions can go here
    export SSH_AUTH_SOCK=/home/quexten/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock
    eval (zellij setup --generate-auto-start fish | string collect)
end
EOF
}

install_flatpaks() {
    echo "Installing Flatpak applications..."
    flatpak install --system -y flathub org.localsend.localsend_app
    flatpak install --system -y com.borgbase.Vorta
    flatpak install --system -y com.teamspeak.TeamSpeak3
    flatpak install --system -y com.protonvpn.www
    flatpak install --system -y org.chromium.Chromium
    flatpak install --system -y org.signal.Signal
    flatpak install --system -y com.discordapp.Discord
    flatpak install --system -y com.bitwarden.desktop
    flatpak install --system -y me.proton.Mail
}

install_games() {
    dnf install steam -y
    dnf install gamescope -y
    dnf install lutris -y
}

install_misc() {
    echo "Installing miscellaneous applications..."
    dnf install mpv -y
    dnf install obs-studio -y
}

ensure_root "$@"
install_flatpaks
install_toolchains
install_dev_tools
configure_fish