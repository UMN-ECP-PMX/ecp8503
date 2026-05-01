fn <- function(x, y) {
  z <- 5 * y
}

# When I change x, what will happen?
# Is z sensitive to x? 
# 
#  numerical_illustration_live.R
# 

CL     <- 0.15        # clearance, L/h
V      <- 8           # volume of distribution, L
D      <- 70          # dose, mg (IV bolus)
sigma2 <- 1           # residual variance (constant)

k <- CL / V                     # elimination rate constant
# what is 1/k? 

M_i <- function(t) {
  prefactor <- D^2 * exp(-2*k*t) / (sigma2 * V^4)
  ktm1      <- k*t - 1
  prefactor * matrix(c(t^2,        -t * ktm1,
                       -t * ktm1,   ktm1^2), nrow = 2, ncol = 2,
                     dimnames = list(c("CL", "V"), c("CL", "V")))
}

# Try it on a single time point
M_at_12h <- M_i(12)

# Talking points:
#  - Note the off-diagonal elements -- these capture CL/V correlation.
#  - At t = 1/k = 53.33, the (V,V) element is almost 0. Try it:
M_i(1/k)

M_list <- lapply(c(1/k, 12), M_i)
M_list


M <- Reduce(`+`, M_list)
detM <- det(M)
#detM
Minv <- solve(M)
rse_CL <- 100 * sqrt(Minv[1,1]) / CL
rse_V  <- 100 * sqrt(Minv[2,2]) / V

Msingular <- lapply(c(53.3, 53.3001, 53.3002), M_i)
Msingular
Ms <- Reduce(`+`, Msingular)
MsInv <- solve(Ms)
det(Ms) # Very small value

rse_CL1 <- 100 * sqrt(MsInv[1,1]) / CL
rse_V1  <- 100 * sqrt(MsInv[2,2]) / V

# plot 
C_t <- function(t) (D/V) * exp(-k*t)
t_grid <- seq(0, 120, length.out = 200)

plot(t_grid, C_t(t_grid), type = "l", lwd = 2,
      xlab = "time (h)", ylab = "C(t)",
       ylim = c(0, D/V * 1.05))
points(c(1/k, 12), C_t(c(1/k, 12)), pch = 19, cex = 1.6)
points(c(53.3, 53.3001, 53.3002), C_t(c(53.3, 53.3001, 53.3002)), pch = 19, cex = 1.6, col="red")
