# PopED requires 3 functions in order to define a model:

# ff(), the structural model;
# fg(), the parameter model (including IIV and IOV);
# feps(), the residual error model.

library(PopED)
library(tidyverse)


ff <- function(model_switch, xt, parameters, poped.db) {
  # `xt` is the vector of sampling times for an individual.
  # `parameters` is a named list of individual parameter values.
  # We return predicted concentrations at `xt`.
  with(as.list(parameters), {
    y <- (DOSE * KA) / (V * (KA - CL / V)) *
         (exp(-CL / V * xt) - exp(-KA * xt))
    return(list(y = y, poped.db = poped.db))
  })
}

fg <- function(x, a, bpop, b, bocc) {
  parameters <- c(
    CL     = bpop[1] * exp(b[1]),
    V      = bpop[2] * exp(b[2]),
    KA     = bpop[3] * exp(b[3]),
    DOSE   = a[1]
  )
  return(parameters)
}

feps <- function(model_switch, xt, parameters, epsi, poped.db) {
  y <- ff(model_switch, xt, parameters, poped.db)[[1]]
  y <- y * (1 + epsi[, 1]) + epsi[, 2]
  return(list(y = y, poped.db = poped.db))
}


poped.database <- create.poped.database(
  ff_fun     = ff,
  fError_fun = feps,
  fg_fun     = fg,

  #  Fixed effects (typical values)
  bpop          = c(CL = 8, V = 12, KA = 1.0),
  notfixed_bpop = c(1, 1, 1),    # 0 = fixed, 1 = estimated. F is fixed.

  # IIV variances (omega^2 on the eta scale) 
  d = c(CL = 0.07, V = 0.09, KA = 0.19),

  # Residual error variances 
  sigma = c(prop = 0.015, add = 0.05),  # 10% proportional + 0.5 ng/mL additive

  # ---- Group / design --------------------------------------------------
  groupsize = 32,                      # 32 subjects in the cohort
  xt        = c(0.5, 2, 12),           # the naive sampling design
  minxt     = 0,
  maxxt     = 12,
  a         = 100                       # 100 mg single oral dose
)

evaluate_design(poped.database)
plot_model_prediction(poped.database)

opt <- poped_optimize(poped.database, opt_xt = T)
summary(opt$poped.db)
plot_model_prediction(opt$poped.db)

plot_efficiency_of_windows(
  opt$poped.db,
  xt_plus  = c(0.25, 0.25, 1),
  xt_minus = c(0.25, 0.25, 1)
)


# D and A optimality
opt.D <- poped_optim(
  poped.database,
  opt_xt = TRUE,
  ofv_calc_type = 1     # Default
)

opt.A <- poped_optim(
  poped.database,
  opt_xt = TRUE,
  ofv_calc_type = 2     # 2 = A-optimal
)

poped.db.ED <- create.poped.database(
  ff_fun     = ff,
  fError_fun = feps,
  fg_fun     = fg,
  bpop = cbind(
    c(4,    4,    4),  # log-normal on CL/V/KA,
    c(CL = 8, V = 25, KA = 1.0), # means
    c(0.05, 0.05, 0.30)^2  # CV^2 — KA is the uncertain one
  ),
  notfixed_bpop = c(1, 1, 1),
  d             = c(CL = 0.07, V = 0.02, KA = 0.6),
  sigma         = c(prop = 0.01, add = 0.25),
  groupsize = 32,
  xt        = c(0.5, 2, 12),
  minxt     = 0, maxxt = 24,
  a         = 100
)

# E[ -log det M(theta, xi) ]  averaged over the prior on bpop
opt.ED <- poped_optim(
  poped.db.ED,
  opt_xt       = TRUE,
  d_switch     = FALSE,   # FALSE => expected D; TRUE => point-D
  ED_samp_size = 20       # K = 20 Monte Carlo draws from the prior
)

results <- data.frame(
  criterion = c("D-optimal", "A-optimal", "ED-optimal"),
  t1 = sapply(list(opt.D, opt.A, opt.ED),
              function(o) round(sort(o$poped.db$design$xt)[1], 2)),
  t2 = sapply(list(opt.D, opt.A, opt.ED),
              function(o) round(sort(o$poped.db$design$xt)[2], 2)),
  t3 = sapply(list(opt.D, opt.A, opt.ED),
              function(o) round(sort(o$poped.db$design$xt)[3], 2))
)
