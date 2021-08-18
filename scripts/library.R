devtools::install_github("DidDrog11/DavidsPack")

if (!require("pacman")) install.packages("pacman")
pkgs = c(
  "here",
  "tidyverse"
)

pacman::p_load(pkgs, character.only = T)