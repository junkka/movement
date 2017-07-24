#' @name movement
#' @aliases movedata
#' @title Popular movement membership
#' @description This data containes information on all known popular movment organizations in Sweden 
#'   1881-1950.
#' @docType data
#' @format A data frame with 674930 rows and 21 variables:
#' \describe{
#'   \item{studienr}{int Archive number}
#'   \item{upplaga}{int Archive code for publishing date }
#'   \item{del}{int Archive data on order within series}
#'   \item{idnummer}{int Unique organization id}
#'   \item{lanskod}{int County code}
#'   \item{ort}{fctr Name of place}
#'   \item{forkod}{int Parish code}
#'   \item{forsnamn}{fctr Parish name}
#'   \item{komkod}{int Municipality code}
#'   \item{komnamn}{fctr Municipality name}
#'   \item{lansnr}{int County code version 2}
#'   \item{hornamn}{fctr Name of district}
#'   \item{orgkod}{int Organizational type code}
#'   \item{orgnamn}{fctr Organizational type name}
#'   \item{avd}{int Unknown}
#'   \item{orgtypk}{int Organizational group code}
#'   \item{orgtypn}{fctr Organizational group name}
#'   \item{year}{int Year}
#'   \item{medl}{dbl Members}
#'   \item{is_approx}{lgl Membership approximation}
#'   \item{geoname1}{fctr Standardised location name 1}
#'   \item{geoname2}{fctr Standardised location name 2}
#'   \item{geoid}{dbl Geographical ID}
#'   \item{lon}{dbl Longitude}
#'   \item{lat}{dbl Latitude}
#' }
#' @usage movement
#' @source Andrae & Lundkvist (1984) \href{http://snd.gu.se/sv/catalogue/study/SND0209}{SND0209}
#' @author Johan Junkka \email{johan.junkka@@umu.se}
NULL

#' @name geocodes
#' @aliases geocodes
#' @title Geocodes
#' @description Geocodes for places in popular movement data. Projection RT90 
#'   ESPG:2400.
#' @docType data
#' @format A data frame with 11385 rows and 3 variables:
#' \describe{
#'   \item{geoid}{int Geolocation id}
#'   \item{lon}{num longitude }
#'   \item{lat}{num latitude}
#' }
#' @usage geocodes
#' @author Johan Junkka \email{johan.junkka@@umu.se}
NULL
