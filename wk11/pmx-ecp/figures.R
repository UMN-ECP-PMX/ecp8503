library(ggplot2)
library(mrggsave)
library(patchwork)
p1 <- ggplot(Theoph, aes(Time, conc, group=Subject)) +
  geom_line() +
  scale_y_log10() +
  theme_bw()

mrggsave(
  p1,
  stem = "fig-conc-time",
  dir = "deliv/figures",
  script = "scripts/figures.R",
  width=8.5,
  height=5,
  fontsize = 11, # Check footnotes size,
  pre_label = "Adding a footnote"
)

p2 <- ggplot(Theoph, aes(Time, conc, group=Subject)) +
  geom_line() +
  scale_y_log10()

mrggsave(
  p1 + p2,
  stem = "fig-conc-time-layout-2",
  dir = "deliv/figures",
  script = "scripts/figures.R",
  width=8.5,
  height=5,
  fontsize = 11
)
