# get_geocodes.R

library(dplyr)
library(ggmap)

plyr::l_ply(c(20:24), function(i){
  a  <- movement %>% filter(lanskod == i) %>% group_by(ort, komnamn, lanskod) %>% summarise(memb = sum(medl, na.rm=T)) %>% mutate(name = paste(ort, komnamn, "Sweden", sep = ", ")) %>% mutate(lat = NA, lon  = NA)
  plyr::l_ply(c(1:nrow(a)), function(j){
    if (is.na(a$lon[j])){
      res <- geocode(a$name[j], output = "latlon")
      a$lat[j] <<- res$lat 
      a$lon[j] <<- res$lon 
    }
  })
  geocoded <- a
  save(geocoded, file = sprintf("data-raw/geocodes/geocode%d.rda", i))
})