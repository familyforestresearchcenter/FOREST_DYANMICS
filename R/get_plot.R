#'get_plot(evalgrp = "12023", statecd.nwos = "1", cnty = "IS NOT NULL")

get_plot <- function(evalgrp, statecd.nwos, cnty, eu)
{
  nims <- odbcConnect("fiadb01p")
  sql <- read.delim("../SQL/get_plot.sql", header=F)
  sql <- paste(sql[,1], collapse = " ")
  sql <- gsub("&EVAL_GRP", evalgrp, sql)
  sql <- gsub("&COUNTY", cnty, sql)
  fa <- as_tibble(sqlQuery(nims, sql)) %>%
    mutate(STATECD_NWOS = statecd.nwos)
  odbcClose(nims)
  return(fa) }