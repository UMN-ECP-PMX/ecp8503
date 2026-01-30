library(yspec)
library(here)
library(dplyr)
library(data.table)
library(haven)


spec <- ys_load(here("wk02/nmdat1.yaml"))

data <- fread(here("model1/data/nmdat1.csv"), na.strings = ".")

data <- ys_add_labels(data, spec)

str(data)

#haven::write_xpt(data, "nmdat1.xpt", name = "nmdat1")

ys_check(data, spec)

ys_document(
  spec, 
  type = "regulatory", 
  output_dir = here("wk02")
)


