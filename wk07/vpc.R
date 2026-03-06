.libPaths("~/Rlibs")

library(mrgsolve)
library(vpc)
library(dplyr)
library(here)
library(data.table)
library(mrgmisc)
library(mrggsave)

options(pillar.width = Inf, mrggsave.dev = "png", mrggsave.res = 300)

figures_to(here("wk07/assets"))

mrg_vpc_theme = new_vpc_theme(list(
  sim_pi_fill = "steelblue3", sim_pi_alpha = 0.3,
  sim_median_fill = "grey60", sim_median_alpha = 0.3
))


mod <- mread(here("wk07/model/106.txt"))

data <- fread(here("wk07/data/analysis3.csv"), na.strings = ".")
data <- mutate(data, DVN = DV/DOSE)

sims <- lapply(seq(300), \(x) {
  mrgsim(mod, data, recover = "DOSE,DVN,EVID,STUDY,STUDYN") %>% 
    mutate(irep = x, YN = Y / DOSE)
}) %>% bind_rows()

fsims <- filter(sims, EVID==0, Y > 10)
fdata <- filter(data, EVID==0, BLQ==0)


# Single dose

O <- filter(fdata, STUDYN == 4 )
S <- filter(fsims, STUDYN == 4 )

p1 <- vpc(
  obs = O,
  sim = S,
  stratify = "STUDY",
  obs_cols = list(dv = "DV"),
  sim_cols = list(dv = "Y", sim = "irep"), 
  log_y = TRUE,
  pi = c(0.05, 0.95),
  ci = c(0.025, 0.975), 
  facet = "rows",
  smooth = TRUE,
  show = list(obs_dv = TRUE), 
  vpc_theme = mrg_vpc_theme
) 

p1 <- 
  p1 +  theme_bw() + 
  geom_hline(yintercept = 10, lty = 2) + 
  ylab("Demothizone concentration (ng/mL)") + 
  xlab("Time (h)")

p1

mrggsave(p1, stem = "study-4", labeller = NULL)


p2 <- vpc(
  obs = O,
  sim = S,
  stratify = "STUDY",
  obs_cols = list(dv = "DV"),
  sim_cols = list(dv = "Y", sim = "irep"), 
  log_y = TRUE,
  pi = c(0.05, 0.95),
  ci = c(0.025, 0.975), 
  facet = "rows",
  smooth = FALSE,
  show = list(obs_dv = TRUE), 
  vpc_theme = mrg_vpc_theme
) 

p2 <- 
  p2 +  
  theme_bw() + 
  geom_hline(yintercept = 10, lty = 2) + 
  ylab("Demothizone concentration (ng/mL)") + 
  xlab("Time (h)")

p2

mrggsave(p2, stem = "study-4-boxes", labeller = NULL)

p3 <- vpc(
  obs = O,
  sim = S,
  stratify = "STUDY",
  obs_cols = list(dv = "DV"),
  sim_cols = list(dv = "Y", sim = "irep"), 
  log_y = TRUE,
  pi = c(0.05, 0.95),
  ci = c(0.025, 0.975), 
  facet = "rows",
  smooth = FALSE,
  show = list(obs_dv = FALSE), 
  vpc_theme = mrg_vpc_theme
) 

p3 <- 
  p3 +  
  theme_bw() + 
  geom_hline(yintercept = 10, lty = 2) + 
  ylab("Demothizone concentration (ng/mL)") + 
  xlab("Time (h)")

p3

mrggsave(p3, stem = "study-4-boxes-noobs", labeller = NULL)


p4 <- vpc(
  obs = O,
  sim = S,
  stratify = "STUDY",
  obs_cols = list(dv = "DV"),
  sim_cols = list(dv = "Y", sim = "irep"), 
  log_y = TRUE,
  pi = c(0.05, 0.95),
  ci = c(0.025, 0.975), 
  facet = "rows",
  smooth = FALSE,
  bins = "time", 
  show = list(obs_dv = FALSE), 
  vpc_theme = mrg_vpc_theme
) 

p4 <- 
  p4 +  
  theme_bw() +
  geom_hline(yintercept = 10, lty = 2) + 
  ylab("Demothizone concentration (ng/mL)") + 
  xlab("Time (h)")

p4

mrggsave(p4, stem = "study-4-boxes-bin", labeller = NULL)
