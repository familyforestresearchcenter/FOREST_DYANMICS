#'get_area(evalgrp = "12023", statecd.nwos = "1", cnty = "IS NOT NULL")

get_base_estimates <- function(evalgrp, statecd.nwos, cnty = "IS NOT NULL", eu = "IS NOT NULL")
{
  nims <- odbcConnect("fiadb01p")
  sql <- read.delim("../SQL/get_base_estimates.sql", header=F)
  sql <- paste(sql[,1], collapse = " ")
  sql <- gsub("&EVAL_GRP", evalgrp, sql)
  sql <- gsub("&COUNTY", cnty, sql)
  sql <- gsub("&ESTN_UNIT", eu, sql)
  fa <- as_tibble(sqlQuery(nims, sql)) %>%
    mutate(STATECD_NWOS = statecd.nwos)
  odbcClose(nims)
  return(fa) }