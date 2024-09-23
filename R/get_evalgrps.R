#' evalgrps.all <- get_evalgrps()
#' write_csv(evalgrps.all, "./DATA/EVAL_GRPS_ALL.csv")

get_evalgrps <- function() {
  require(tidyverse)
  require(RODBC)
  nims <-  odbcConnect("fiadb01p")
  sql <- read.delim("SQL/get_evalgrps.sql", header=F)
  sql <- paste(sql[,1], collapse = " ")
  as_tibble(sqlQuery(nims, sql)) }