# make_shp.R

library(movement)
library(dplyr)
library(tidyr)
data(movement)

dat <- movement %>% group_by(geoid, orgtypn, year, lon, lat) %>% 
  summarise(memb = sum(medl, na.rm = T)) %>% 
  as.data.frame() %>% 
  spread(year, memb) 

library(sp)
library(rgdal)
dat2 <- dat %>% filter(-lon, -lat)

crs <- CRS("+proj=tmerc +lat_0=0 +lon_0=15.80827777777778 +k=1 +x_0=1500000 +y_0=0 +ellps=bessel +units=m +no_defs")
popmove <- SpatialPointsDataFrame(dat[ ,c("lon", "lat")], proj = crs, data = dat2)

writeOGR(popmove, "popmove", "popmove", driver="ESRI Shapefile")
