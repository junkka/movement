# geocode places

library(stringr)
library(sp)
library(rgdal)
library(dplyr)

load("data/movement.rda")

message("Aggregating by geocode")
files <- list.files("data-raw/geocodes/")
file_nrs <- as.numeric(str_extract(files, "[0-9]{1,2}"))

res <- plyr::ldply(c(1:25), function(i) {
  message(i)
  env <- environment()
  load(sprintf("data-raw/geocodes/geocode%d.rda", i), envir = env)
  if (ncol(geocoded) == 18) {
    geocoded <- geocoded %>% select(name = query, lon, lat)
    a  <- movement %>% filter(lanskod == i) %>%
      group_by(ort, komnamn, lanskod) %>%
      summarise(memb = sum(medl, na.rm=T)) %>%
      mutate(name = paste(ort, komnamn, "Sweden", sep = ", "))
    res <- left_join(a, geocoded, by = "name")
  } else {
    res <- geocoded
  }
  return(res)
})
geocodes <- select(res, ort:lanskod, lon, lat)
geocodes$geoid <- as.integer(rownames(geocodes))
# geocodes %>% filter(is.na(lon)) %>% write.csv("data-raw/manual-geocodes.csv")
save(geocodes, file = "data-raw/geocodes.rda")

message("Add manual codes")
load("data-raw/geocodes.rda")

manual_geo <- read.csv("data-raw/manual-geocodes.csv") %>% 
  select(lat1 = lat, lon1 = lon, geoid)

geocodes <- left_join(geocodes, manual_geo, by = "geoid") %>% 
  mutate(
    lon = ifelse(is.na(lon), lon1, lon),
    lat = ifelse(is.na(lat), lat1, lat)
  ) %>% 
  select(-lon1, -lat1)

utf8_factor <- function(x){
  x <- as.character(x) %>% 
    iconv("utf8", "utf8")
  str_replace_all(x, "\\$", "å")
}

geocodes <- geocodes %>% 
  mutate(
    ort = utf8_factor(ort),
    komnamn = utf8_factor(komnamn)
  )

movement <- movement %>% 
  mutate(
    ort = utf8_factor(ort),
    komnamn = utf8_factor(komnamn)
  )

message("Project geocodes")

movement <- left_join(movement, geocodes, by = c("lanskod", "komnamn", "ort"))

geocodes <- geocodes %>% select(geoid, lon, lat)
crs <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
sp_gdat <- SpatialPointsDataFrame(geocodes[ ,c("lon", "lat")], proj = crs, data = select(geocodes, geoid))
sp_gdat <- spTransform(sp_gdat, CRS("+init=epsg:2400"))
geocodes <- as.data.frame(sp_gdat)
save(geocodes, file = "data/geocodes.rda")

# # assign id to geocodes add geoid to movement
message('Adding geodata to movement')

movement <- movement %>% 
  select(-lon, -lat) %>% 
  left_join(geocodes, by = "geoid") 

message('Saving data')
save(movement,
    file = 'data/movement.rda', 
    compress='xz')


# cent_lon <- min(geocodes$lon) + ((max(geocodes$lon) - min(geocodes$lon)2)/2)
# cent_lat <- min(geocodes$lat) + ((max(geocodes$lat) - min(geocodes$lat))/2)

# map <- get_map(location = c(cent_lon, cent_lat), 
#   maptype = 'roadmap', zoom = 7)
# p <- ggmap(map)
# p + geom_point(data=geocodes, aes(lon, lat, size = memb, alpha = 0.1, fill = "black")) + 
#   geom_text(data = geocodes, aes(label=ort))

# a3 <- geocodes %>% filter(!is.na(lon))
# sp_p <- SpatialPointsDataFrame(a3[ ,c("lon", "lat")], proj=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"), data = a3)
# proj4string(sp_p) <- CRS("+proj=longlat")
# sp_p2 <- spTransform(sp_p, CRS("+init=epsg:2400"))
# sp_p2 <- spTransform(sp_p, CRS("+proj=utm +zone=33"))