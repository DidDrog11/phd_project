source(here::here("scripts", "library.R"))
remotes::install_github("giocomai/ganttrify")
library("ganttrify")

gantt_activities <- readxl::read_excel(here("data", "project_timelines.xlsx"), sheet = 1)
gantt_spots <- readxl::read_excel(here("data", "project_timelines.xlsx"), sheet = 2)

gantt_chart <- ganttrify(project = gantt_activities,
          spots = gantt_spots,
          by_date = TRUE,
          project_start_date = "2020-09",
          size_text_relative = 1.2, 
          axis_text_align = "left",
          mark_quarters = TRUE,
          font_family = "Roboto Condensed",
          colour_palette = wesanderson::wes_palette("Zissou1", n = 8, type = "continuous")) +
  theme(axis.text.y = element_text(hjust = 0),
        axis.text.x = element_text(color = c("gray30", 0, 0))) +
  labs(title = "PhD project timeline, 2020-2023",
       caption = "C = completed, F = Failed to achieve, O = PhD output, S = PhD submission deadline")

ggsave(filename = here("output", "gantt.png"), dpi = 300, plot = gantt_chart,
       width = 10, height = 11)