library(mrgsolve)

# Example from:
# https://github.com/metrumresearchgroup/optimal-design/
model_mrg <- "
[ param ]
CL = 1, VMAX = 10, KM = 10, V1 = 8, Q = 10, V2 = 100

[ cmt ] CENT PERIPH

[ main ]
double ke  = CL/V1;
double k12 = Q/V1;
double k21 = Q/V2;

[ ode ]
double CP = CENT/V1;

dxdt_CENT = k21*PERIPH - k12*CENT - VMAX*CP/(KM + CP) - ke*CENT;
dxdt_PERIPH = k12*CENT - k21*PERIPH;

[ capture ]
CP
"
mod <- mcode("poped", model_mrg)

ff <- function(model_switch, xt, parameters, poped.db) {
  
  obs_time <- as.numeric(xt)
  dose_time <- 0
  
  dose <- data.frame(
    ID = 1, 
    amt = parameters[["DOSE"]]*1000,
    cmt = 1, 
    evid = 1,
    time = dose_time
  )
  
  obs <- data.frame(
    ID = 1, 
    amt = 0, 
    cmt = 1, 
    evid = 0, 
    time = sort(obs_time)
  )
  
  data <- arrange(bind_rows(dose,obs),time)
  
  mod <- param(mod, parameters)
  
  out <- mrgsim_q(mod,data,output="matrix")
  
  out <- out[data$evid==0,"CP",drop=FALSE][match(obs_time,obs$time),]
  
  return(list(y = out, poped.db = poped.db))
}

fg <- function(x, a, bpop, b, bocc){
  parameters = c(
    CL    = bpop[1] * exp(b[1]),
    VMAX  = bpop[2] * exp(b[2]),
    KM    = bpop[3],
    V1    = bpop[4] * exp(b[3]),
    Q     = bpop[5],
    V2    = bpop[6],
    DOSE  = a[1] 
  )
  return(parameters) 
}

poped_db_mrg <- create.poped.database(
  ff_fun = ff,
  fg_fun = fg,
  fError_fun = feps.prop,
  bpop = c(CL = 0.5, VMAX = 20, KM = 1.2, V1 = 2.5, Q = 10, V2 = 4), 
  notfixed_bpop = c(1, 1, 1, 1, 1, 1),
  d = c(CL = 0.2, VMAX = 0.2, V1 = 0.1),
  sigma = c(0.15),
  m = 6,
  groupsize = 6,
  xt = c(c(1, 4)/24, 1, 3, 7, 14, 21),
  minxt = 0,
  maxxt = 21,
  #discrete_xt = list(c((1:4)/24, 1:21)),
  bUseGrouped_xt = TRUE,
  a = cbind(DOSE = c(0.03, 0.1, 0.3, 1, 3, 10))
)

plot_model_prediction(
  poped_db_mrg,
  model_num_points = 200
) +
  labs(x = "Time from dose (days)") +
  scale_y_log10(lim = c(0.01, 1e4))


FIM_mrg <- evaluate.fim(poped_db_mrg) 
get_rse(FIM_mrg, poped_db_mrg)

p <- plot_efficiency_of_windows(
  poped_db_mrg,
  xt_plus  = c(rep(1/24, 2), rep(3/24, 5)),
  xt_minus = c(rep(1/24, 2), rep(3/24, 5))
)
