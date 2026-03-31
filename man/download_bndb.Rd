\name{download_bndb}
\title{download_bndb: Download occurrence data from BNDB Ecuador}
\usage{
download_bndb(scientific_name, max_pages = 10, delay = 0.5, polygon = NULL,
crs = "EPSG:32717", output = "csv", map = FALSE, out_file = NULL)
}
\arguments{
  \item{scientific_name}{Scientific name of the species}
  \item{max_pages}{Maximum number of pages to download}
  \item{delay}{Delay between requests in seconds}
  \item{polygon}{Path to shapefile or GeoJSON, or sf object}
  \item{crs}{Coordinate Reference System (e.g., EPSG:32717, EPSG:4326)}
  \item{output}{Output format: "csv" or "shp"}
  \item{map}{Display interactive map: TRUE or FALSE}
  \item{out_file}{Output filename without extension}
}
\value{
  Data frame with occurrence records
}
\description{
  Downloads occurrence data from the Banco Nacional de Datos de Biodiversidad (BNDB) of Ecuador.
}
\examples{
\dontrun{
library(rbndb)
occ <- download_bndb("Cedrela odorata")
occ <- download_bndb("Cedrela odorata", polygon = "shape.shp", crs = "EPSG:32717")
}
}
\keyword{package}
