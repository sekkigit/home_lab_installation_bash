#!/bin/bash

source .var

mv /home/$USER/docker/homer/config.yml /home/$USER/docker/homer/config.yml.original

cat <<EOF > /home/$USER/docker/homer/config.yml
# Homepage configuration
# See https://fontawesome.com/icons for icons options

title: "Home-Lab"
subtitle: "Dashboard"

header: true
footer: false

# Optional theme customization
theme: default
colors:
  light:
    highlight-primary: "#3367d6"
    highlight-secondary: "#4285f4"
    highlight-hover: "#5a95f5"
    background: "#f5f5f5"
    card-background: "#ffffff"
    text: "#363636"
    text-header: "#ffffff"
    text-title: "#303030"
    text-subtitle: "#424242"
    card-shadow: rgba(0, 0, 0, 0.1)
    link: "#3273dc"
    link-hover: "#363636"
  dark:
    highlight-primary: "#3367d6"
    highlight-secondary: "#4285f4"
    highlight-hover: "#5a95f5"
    background: "#131313"
    card-background: "#2b2b2b"
    text: "#eaeaea"
    text-header: "#ffffff"
    text-title: "#fafafa"
    text-subtitle: "#f5f5f5"
    card-shadow: rgba(0, 0, 0, 0.4)
    link: "#3273dc"
    link-hover: "#ffdd57"

# Optional message
#message:
#  style: "is-dark"
#  title: "Samba"
#  content: "Open in file explorer for the file server: 192.168.1.19"

# Optional navbar
# links: [] # Allows for navbar (dark mode, layout, and search) without any links
links:
  - name: "Seki Git-Hub"
    icon: "fab fa-github"
    url: "https://github.com/sekkigit/Home-Lab.git"
    target: "_blank" # optional html a tag target attribute
  - name: "Sekith.xyz"
    icon: ""
    url: "https://sekiteh.xyz"
    target: "_blank" # optional html a tag target attribute

# Services
# First level array represent a group.
# Leave only a "items" key if not using group (group name, icon & tagstyle are optional, section separation will not be displayed).
services:
  - name: "Applications"
    icon: "fas fa-cloud"
    items:
      - name: "SpeedTest"
        logo: "https://play-lh.googleusercontent.com/xKUdbWyGGv4lbYH5Fzrz-USBEKk84Aw43IPmnl9VVq4jewz4y8JrwOivPsAYCtTbDbdt"
        subtitle: "OpenSpeedTest"
        url: "https://speedtest.sekiteh.xyz/"
        target: "_blank"
      - name: "Plex"
        logo: "https://www.feirox.com/rivu/2015/12/PlexforAndroid-3.png"
        subtitle: "Media server"
        url: "https://app.plex.tv/desktop/#!/"
        target: "_blank"
      - name: "Grafana"
        logo: "https://upload.wikimedia.org/wikipedia/commons/9/9d/Grafana_logo.png"
        subtitle: "Console"
        url: "https://graf.sekiteh.xyz"
        target: "_blank"

  - name: "Local applications"
    icon: "fas fa-local"
    items:
      - name: "Nginx Proxy Menager"
        logo: "https://nginxproxymanager.com/icon.png"
        subtitle: "Proxy menager"
        tag: "Intrnal"
        url: "http://$IP:81"
        target: "_blank"
      - name: "Portainer"
        logo: "https://cdn.iconscout.com/icon/free/png-256/docker-226091.png"
        subtitle: "Docker menager"
        tag: "Intrnal"
        url: "http://$IP:9000"
        target: "_blank"
      - name: "Cockpit"
        logo: "https://avatars.githubusercontent.com/u/5765104?s=280&v=4"
        subtitle: "Server menager"
        tag: "Intrnal"
        url: "http://$IP:9090"
        target: "_blank"
EOF