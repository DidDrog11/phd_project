# devtools::install_github("DidDrog11/DavidsPack")
remotes::install_github("giocomai/ganttrify")

if (!require("pacman")) install.packages("pacman")
pkgs = c(
  "here",
  "tidyverse",
  "ganttrify"
)

pacman::p_load(pkgs, character.only = T)
