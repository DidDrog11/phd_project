source(here::here("scripts", "library.R"))

gantt_activities <- readxl::read_excel(here("data", "project_timelines.xlsx"), sheet = 1)

gantt_spots <- readxl::read_excel(here("data", "project_timelines.xlsx"), sheet = 2)

project = gantt_activities
spots = gantt_spots
month_breaks = 1
colour_stripe = "lightgray"
size_wp = 4
size_activity = 2
size_text_relative = 1
axis_text_align_n = 1
line_end = "round"
font_family = "sans"

colour_palette <- wesanderson::wes_palette("Zissou1")
if (length(unique(project$wp)) > length(as.character(wesanderson::wes_palette("Zissou1")))) {
    colour_palette <- wesanderson::wes_palette(length(unique(project$wp)), name = "Zissou1", type = "continuous")
}

df_yearmon <- project %>% mutate(start_date_yearmon = zoo::as.yearmon(start_date), 
                                        end_date_yearmon = zoo::as.yearmon(end_date)) %>% 
  transmute(wp = as.character(wp), activity = as.character(activity), 
                   start_date = zoo::as.Date(start_date_yearmon, 
                                             frac = 0), end_date = zoo::as.Date(end_date_yearmon, 
                                                                                frac = 1))

df <- project %>% mutate(start_date = as.Date(start_date), 
                                end_date = as.Date(end_date), 
                                wp = as.character(wp), 
                                activity = as.character(activity))

sequence_months <- seq.Date(from = min(df_yearmon[["start_date"]]), 
                            to = max(df_yearmon[["end_date"]]), by = "1 month")

date_range_matrix <- matrix(as.numeric(sequence_months), 
                            ncol = 2, byrow = TRUE)

date_range_df <- tibble::tibble(start = zoo::as.Date.numeric(date_range_matrix[,1]),
                                end = zoo::as.Date.numeric(date_range_matrix[,2]))
  
date_breaks <- zoo::as.Date(zoo::as.yearmon(seq.Date(from = min(df_yearmon[["start_date"]] + 15),
                                                     to = max(df_yearmon[["end_date"]] + 15),
                                                     by = paste(month_breaks, "month"))), frac = 0.5)
  
date_breaks_q <- seq.Date(from = lubridate::floor_date(x = min(df_yearmon[["start_date"]]), unit = "year"),
                          to = lubridate::ceiling_date(x = max(df_yearmon[["end_date"]]), unit = "year"),
                          by = "1 quarter")
  
date_breaks_y <- seq.Date(from = lubridate::floor_date(x = min(df_yearmon[["start_date"]]), unit = "year"),
                          to = lubridate::ceiling_date(x = max(df_yearmon[["end_date"]]), unit = "year"),
                          by = "1 year")

df_levels <- rev(df_yearmon %>% 
  select(wp, activity) %>% 
  t() %>% as.character() %>% unique())

df_yearmon_fct <- bind_rows(activity = df, wp = df %>% 
                                     group_by(wp) %>% 
                                     summarise(activity = unique(wp), 
                                                      start_date = min(start_date),
                                                      end_date = max(end_date)), .id = "type") %>% 
  mutate(activity = factor(x = activity, levels = df_levels)) %>% 
  arrange(activity)

df_yearmon_fct$wp_alpha <- 1
df_yearmon_fct$activity_alpha <- 1

spots_date <- spots %>% drop_na() %>% 
  mutate(activity = as.character(activity)) %>% 
  mutate(activity = factor(x = activity, 
                                  levels = df_levels), spot_date = as.Date(spot_date), 
                end_date = as.Date(NA), wp = NA) %>%
  drop_na(activity)

gantt_chart <- ggplot(data = df_yearmon_fct, 
                   mapping = aes(x = start_date, y = activity, xend = end_date, yend = activity, colour = wp)) + 
  geom_rect(data = date_range_df, 
            aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf), inherit.aes = FALSE,  alpha = 0.4, fill = colour_stripe) + 
  geom_vline(xintercept = date_breaks_q, colour = "gray50") + 
  geom_vline(xintercept = date_breaks_y, colour = "gray50") + 
  geom_vline(xintercept = Sys.Date(), colour = "darkred") +
  geom_segment(data = df_yearmon_fct, lineend = line_end, size = size_activity, alpha = df_yearmon_fct$activity_alpha) + 
  geom_segment(data = df_yearmon_fct, lineend = line_end, size = size_wp, alpha = df_yearmon_fct$wp_alpha) + 
  scale_x_date(name = "", breaks = date_breaks, date_labels = "%b\n%Y", minor_breaks = NULL,
               sec.axis = dup_axis(labels = paste0("M", seq_along(date_breaks) * month_breaks - (month_breaks -1)))) +
  scale_y_discrete("") + 
  theme_minimal() + 
  scale_colour_manual(values = colour_palette) + 
  theme(text = element_text(family = font_family), axis.text.y.left = element_text(face = ifelse(test = df_yearmon_fct %>% 
                                                                                                   distinct(activity, wp, type) %>% pull(type) == 
                                                                                                   "wp", yes = "bold", no = "plain"), size = rel(size_text_relative), 
                                                                                   hjust = axis_text_align_n), axis.text.x = element_text(size = rel(size_text_relative)), 
        legend.position = "none") + 
  geom_label(data = spots_date, 
             mapping = aes(x = spot_date, y = activity, label = spot_type),
             colour = "gray30", fontface = "bold", family = font_family, size = 3 * size_text_relative) + 
  theme(panel.grid.major.x = element_line(size = 0))


ggsave(filename = here("output", "gantt.pdf"), plot = gantt_chart, device = cairo_pdf,
       width = 12, height = 14)
ggsave(filename = here("output", "gantt.svg"), plot = gantt_chart,
       width = 12, height = 14)
