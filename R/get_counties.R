get_counties <- function(statecd.nwos) {
  paste0("IN (", paste(ref.cnty %>% 
                         filter(STATECD_NWOS == statecd.nwos) %>% 
                         pull(COUNTYCD), 
                       collapse = ", "), ")") }