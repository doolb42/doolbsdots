#!/bin/bash
# install essential packages
sudo pacman -S --needed base-devel git neovim fish
# install yay if needed
# link configs
ln -sf ~/dotfiles/config/nvim ~/.config/nvim
ln -sf ~/dotfiles/config/waybar ~/.config/waybar
ln -sf ~/dotfiles/config/hypr ~/.config/hypr

