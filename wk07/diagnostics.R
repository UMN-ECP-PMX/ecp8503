.libPaths("~/Rlibs")

library(mrgsolve)
library(vpc)
library(dplyr)
library(here)
library(data.table)
library(mrgmisc)
library(mrggsave)
library(pmplots)
library(patchwork)

options(pillar.width = Inf, mrggsave.dev = "png", mrggsave.res = 300)
options(mrggsave.label.fun = NULL)

figures_to(here("wk07/assets"))

x <- fread(here("wk07/data/pk.csv"), na.strings = ".")
y <- fread(here("wk07/model/99/99.tab"), skip = 1) %>% select(-DV)

data0 <- left_join(y,x) %>% filter(EVID==0)
data0 <- mutate(
  data0, 
  RF = factor(RF, levels = c("norm", "mild", "mod", "sev")), 
  DOSE = factor(DOSE)
)
id0 <- slice(data0, 1, .by = ID)


nm <- left_join(b,c) %>% left_join(a)

data <- filter(nm, EVID==0, STUDYN %in% c(1,4))
id <- slice(data, 1, .by = ID) %>% mutate(CP = factor(CP))

a <- fread(here("wk07/data/analysis3.csv"), na.strings = ".")
b <- fread(here("wk07/model/106/106.tab"), skip = 1) %>% select(-DV)
c <- fread(here("wk07/model/106/106par.tab"), skip = 1)

nm <- left_join(b,c) %>% left_join(a)

datax <- filter(nm, EVID==0)
idx <- slice(datax, 1, .by = ID)

data <- filter(nm, EVID==0, STUDYN %in% c(1,4))
id <- slice(data, 1, .by = ID)

data2 <- filter(nm, EVID==0, STUDYN==3)
id2 <- slice(data2, 1, .by = ID)

wrap_dv_preds(data0)
mrggsave_last(stem = "dv-pred-base", width = 7, height = 3, labeller = NULL)

dv_pred(data0, scales = "free") + 
  facet_wrap(~RF, scales = "free", ncol = 2)

mrggsave_last(stem = "dv-pred-base-egfr", width = 9, height = 6, labeller = NULL)

dv_pred(datax, scales = "free") + 
  facet_wrap(~RF, scales = "free", ncol = 2)

mrggsave_last(stem = "dv-pred-final-egfr", width = 9, height = 6, labeller = NULL)


res_time(data) + wres_time(data) + cwres_time(data) + npde_time(data)
mrggsave_last(stem = "cwres-npde-time", width = 9, height = 6, labeller = NULL)

res_pred(data) + wres_pred(data) + cwres_pred(data) +  npde_pred(data)
mrggsave_last(stem = "cwres-npde-pred", width = 9, height = 6, labeller = NULL)

npde_hist_q(data, ncol = 2)
mrggsave_last(stem = "npde-hist", width = 8, height = 4, labeller = NULL)

data <- mutate(data, NPDE2 = rt(n(), df = 1))
data <- mutate(data, NPDE2 = ifelse(NPDE2 < -6 | NPDE2 > 6, NA_real_, NPDE2))
npde_hist(data, x = "NPDE2") + npde_q(data, x = "NPDE2")
mrggsave_last(stem = "npde-hist-non", width = 8, height = 4, labeller = NULL)


npde_covariate(data2, x = c("EGFR//eGFR", "RF//Renal impairment group"))
mrggsave_last(stem = "npde-covariate", width = 8, labeller = NULL)

npde_covariate(data0, x = c("EGFR//eGFR", "RF//Renal impairment group"))
mrggsave_last(stem = "npde-covariate-base", width = 8, height = 4, labeller = NULL)

etas <- paste0("ETA", c(3,2,1), "//ETA-", c("CL", "V2", "KA"))
eta_hist(id0, etas) %>% pm_grid(ncol = 3)
mrggsave_last(stem = "eta-histogram", width = 9, height = 4, labeller = NULL)

eta_covariate(id0, x = c("EGFR", "RF", "WT", "DOSE"), 
              y = "ETA3//ETA-CL", ncol = 2) %>% rot_xy()
mrggsave_last(stem = "eta-covariate-base", width = 9, height = 6, labeller = NULL)


eta_pairs(id0, etas)
mrggsave_last(stem = "eta-pairs", width = 6, height = 6, labeller = NULL)
