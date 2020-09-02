require("tidyverse")
remotes::install_github("giocomai/ganttrify")
library("ganttrify")
require("here")

gantt_activities <- readxl::read_excel(here("raw_data", "project_timelines.xlsx"), sheet = 1)
gantt_spots <- readxl::read_excel(here("raw_data", "project_timelines.xlsx"), sheet = 2)

ggsave("gantt.png",
       ganttrify(project = gantt_activities,
          spots = gantt_spots,
          by_date = TRUE,
          project_start_date = "2020-09",
          size_text_relative = 1.2, 
          mark_quarters = TRUE,
          font_family = "Roboto Condensed")+
         theme(axis.text.y = element_text(hjust = 0),
               axis.text.x = element_text(color = c("gray30", 0, 0))),
       height = 20,
       width = 30,
       units = "cm",
       path = here("output"))