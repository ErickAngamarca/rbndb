\name{download_bndb}
\title{download_bndb: Download occurrence data from BNDB Ecuador}
\usage{
download_bndb(scientific_name, max_pages = 10, delay = 0.5, polygon = NULL,
crs = "EPSG:32717", output = "csv", map = FALSE, out_file = NULL)
}
\arguments{
  \item{scientific_name}{Scientific name}
  \item{max_pages}{Max pages}
  \item{delay}{Delay seconds}
  \item{polygon}{Polygon path}
  \item{crs}{CRS}
  \item{output}{csv or shp}
  \item{map}{TRUE or FALSE}
  \item{out_file}{Output file}
}
\value{
  Data frame
}
\description{
Download from BNDB Ecuador
}
\examples{
library(rbndb)
occ <- download_bndb("Cedrela odorata")
}
\keyword{package}
