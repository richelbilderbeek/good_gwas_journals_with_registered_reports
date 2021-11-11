# 
# 0. install prerequisites
# 1. 'registered_report_journal_names': the journals that do a registered report
# 2. 'bfis': tibble with journal names and BFI's
# 3. 't': the journals that do a registered report and their BFI

# 
# 0. install prerequisites
#
remotes::install_github("maxconway/gsheet")

#
# 1. 'registered_report_journal_names': the journals that do a registered report
#
registered_report_journals <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1D4_k-8C_UENTRtbPzXfhjEyu3BfLxdOsn9j-otrO870/edit#gid=0")

# We only care about the names, which are in the first column
all_journal_names <- registered_report_journals[ , 1]

# There are four NAs:
# journal_names[2]: due to header
# journal_names[298]: start of journals are listed that are NOT registered reports 
# journal_names[301]: end
# journal_names[302]: end
# After the second NA, journals are listed that are NOT registered reports
# Keep the names between the first and second NA
testthat::expect_equal(4, sum(is.na(all_journal_names)))

first_na_index <- which(is.na(all_journal_names))[1]
second_na_index <- which(is.na(all_journal_names))[2]
from_index <- first_na_index + 1
to_index <- second_na_index - 1

registered_report_journal_names <- all_journal_names[from_index:to_index, ]
names(registered_report_journal_names) <- "registered_report_journal_names"
registered_report_journal_names

#
# 2. 'bfis': tibble with journal names and BFI's
#
bfis_filename <- "~/bfi-listen-for-serier-2021.xlsx"
download.file(
  url = "https://ufm.dk/forskning-og-innovation/statistik-og-analyser/den-bibliometriske-forskningsindikator/BFI-lister/bfi-listen-for-serier-2021.xlsx",
  destfile = bfis_filename
)
testthat::expect_true(file.exists(bfis_filename))
bfis <- xlsx::read.xlsx(
  file = bfis_filename,
  sheetIndex = 1
)

names(bfis)
bfis$Titel
names(bfis)

sum(registered_report_journal_names %in% bfis$Titel)

t <- merge(
  x = registered_report_journal_names,
  y = dplyr::select(bfis, "Titel", "Faggruppenavn", "Niveau"),
  by.x = "registered_report_journal_names",
  by.y = "Titel"
)
research_areas <- c(
  "Biologi", "Medicin", "Folkesundhed", 
  "Medicinsk teknologi", "Generelle serier"
)
knitr::kable(t[t$Faggruppenavn %in% research_areas, ])

