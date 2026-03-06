.libPaths("~/renv/renv/library/R-4.5/aarch64-apple-darwin20/")
library(pmplots)
library(yspec)
library(dplyr)
library(here)
library(ggplot2)
library(data.table)
theme_set(theme_bw())

data <- fread(here("model1/data/nmdat1.csv"), na.strings = ".")

ggplot(data, aes(TIME, DV)) + geom_point() + scale_y_log10()

filter(data, EVID==1) %>% count(TIME, AMT)

filter(data, EVID==0, BLQ==1) %>% count(TIME)
filter(data, EVID==0, BLQ==1) 
filter(data, EVID==0, BLQ==0) %>% arrange((DV)) 

ggplot(data, aes(TIME, DV)) + geom_point() + scale_y_log10() + facet_wrap(~DOSE)

ggplot(data, aes(TIME, DV)) + geom_point() + scale_y_log10() + facet_grid(DOSE~GENO) + 
  geom_hline(yintercept = c(1000, 300), lty = 2)






