# create_moevement.R
library(zoo)
library(stringr)
library(tidyr)
library(dplyr)


get_movement_raw <- function() {
  message('Import source csv')
  raw_data <- read.csv('data-raw/folkrorelse.csv.gz', nrows=41315, encoding = "UTF-8", stringsAsFactors = FALSE)
  colnames(raw_data) <- tolower(colnames(raw_data)) 
  colnames(raw_data) <- gsub('^me[dl]{2}', 'medl', colnames(raw_data))
  return(raw_data)
}

raw_data <- get_movement_raw()

message('Tidying data')

f <- function(a){
  if (inherits(a, "character"))
    factor(iconv(a, "utf8", "utf8"))
  else
    a
}

raw_data <- plyr::colwise(f)(raw_data)

levels(raw_data$orgnamn) <- tolower(levels(raw_data$orgnamn))
levels(raw_data$orgtypn) <- tolower(levels(raw_data$orgtypn))
levels(raw_data$ort)     <- tolower(levels(raw_data$ort))
levels(raw_data$komnamn) <- tolower(levels(raw_data$komnamn))

f2 <- function(a){
  factor(str_replace_all(a, "\\$", "å"))
}

raw_data <- raw_data %>% 
  mutate(
    ort = f2(ort),
    forsnamn = f2(forsnamn),
    hornamn = f2(hornamn),
    orgnamn = f2(orgnamn)
  )

replace_na <- function(x) {
  y <- ifelse(x %in% c(9999, 99999), NA, x)
}
replace_na0 <- function(x) {
  x <- replace_na(x)
  x[x == 0] <- NA
  return(x)
}
between <- function(a, b, d){
  x <- ifelse(a >= b & a <= d, TRUE, FALSE)
  x <- ifelse(is.na(b) | is.na(d), FALSE, x)
  return(x)
}
long <- raw_data %>% 
  select(-x) %>% 
  gather(year, medl, -studienr:-nedlagg2t) %>% 
  mutate(
    medl      = replace_na(medl),
    nedlagg1f = replace_na0(nedlagg1f),
    nedlagg1t = replace_na0(nedlagg1t),
    nedlagg2f = replace_na0(nedlagg2f),
    nedlagg2t = replace_na0(nedlagg2t),
    year      = as.integer(gsub('medl', '', year))
  ) %>% 
  filter(
    year >= inledar & 
    year <= slutar & 
    between(year, nedlagg1f, nedlagg1t) == FALSE & 
    between(year, nedlagg2f, nedlagg2t) == FALSE
  ) %>% 
  select(
    -matrind1:-nedlagg2t
  )

message('Removing extreme outliers')
long_outs <- long %>% 
  group_by(idnummer) %>% 
  # filter(idnummer == 240128) %>% 
  mutate(
    expected = (lead(medl) + lag(medl))/2,
    expected = ifelse(is.na(expected), (lead(medl, 2) + lead(medl))/2, expected),
    expected = ifelse(is.na(expected), (lag(medl, 2) + lag(medl))/2, expected),
    nulls = ifelse(lead(medl) == 0 | lag(medl) == 0, FALSE, TRUE),
    nulls = ifelse(is.na(nulls), TRUE, nulls),
    out = ifelse((expected * 10) < medl & medl > 10 & nulls, TRUE, FALSE),
    out = ifelse(is.na(out), FALSE, out)
  ) %>% ungroup()

long_fin <- ungroup(long_outs) %>% 
  mutate(
    ori_medl = medl,
    medl = ifelse(out, expected, medl),
    is_approx = ifelse(out, TRUE, FALSE)
  ) %>% 
  select(-expected, -nulls, -out)

message('Imputing missing values')
approx_na <- function(year, medl) {
  if (length(na.omit(medl)) < 2){
    return(as.numeric(medl))
  }
  b <- zoo(data.frame(year = year, medl = medl))
  bb <- na.approx(b)
  return(as.numeric(bb$medl))
}
long2 <- long_fin %>% 
  group_by(idnummer) %>% 
  mutate(
    a_medl = approx_na(year, medl),
    is_approx = ifelse(is_approx, TRUE, ifelse(is.na(medl) & !is.na(a_medl), TRUE, FALSE)),
    medl = a_medl
  ) %>% 
  select(-a_medl)


movement <- as.data.frame(long2)

geokod1 <- read.csv("data-raw/geografisk_kod.csv", encoding = "utf8", stringsAsFactors = FALSE)

geokod1 <- plyr::colwise(f)(geokod1)

m <- select(geokod1, code, geoname1 = name) %>% 
  left_join(movement, ., by = c("geokod1" = "code")) 
movement <- select(geokod1, code, geoname2 = name) %>% 
  left_join(m, ., by = c("geokod2" = "code")) %>% 
  select(-geokod1, -geokod2)

message('Saving data')
save(movement,
  file = 'data/movement.rda', 
  compress='xz')

