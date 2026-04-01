library(pmtables)
library(tidyverse)
data <- stdata()
tables_path = here::here("deliv", "tables")
table_1_output = here::here(tables_path, "tbl-summary.tex")
out <- stable(data, panel = "STUDY",
              cols_bold = T,
              output_file = "deliv/tables/tbl-summary.tex",
              r_file = "scripts/tables.R",
              align = cols_align(
                DOSE = col_ragged(7)
              ))

out |> stable_save()

data <- mutate_at(data, vars(WT,CRCL,AGE,ALB), as.numeric)
out.long <- pt_cont_long(data, cols = "WT,CRCL,AGE,ALB")

outfile <- stable_long(out.long,
                       lt_cap_text = "Continous Covariate Descriptive Statistics",
                        lt_cap_label = "tab:ConCov",
            output_file = "deliv/tables/tbl-summary-long.tex",
            r_file = "scripts/tables.R",
            align = cols_align(
              Variable = col_ragged(8)
            ),
            note_config = noteconf(width = 1,
                                   hline = "none",note_skip = 0.1,
                                  type = "minipage",),
            cols_bold = T)
outfile |> stable_save()
