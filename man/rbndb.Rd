\name{rbndb}
\docType{package}
\title{rbndb: Download Data from BNDB Ecuador}
\keyword{package}

DESCRIPTION{
R package to download occurrence data from the Banco Nacional de Datos de 
Biodiversidad (BNDB) of Ecuador via web scraping.
}

\section{Functions}{

download_bndb: Downloads occurrence data from BNDB.

}

\section{Arguments}{

scientific_name: Scientific name (e.g., Cedrela odorata)
max_pages: Maximum pages (default 10)
delay: Delay in seconds (default 0.5)
polygon: Path to shapefile or sf object
crs: Coordinate system (EPSG:32717 default)
output: csv or shp
map: TRUE or FALSE
out_file: Output filename

}

\section{Examples}{


library(rbndb)
occ <- download_bndb("Cedrela odorata")
occ <- download_bndb("Cedrela odorata", polygon = "shape.shp", crs = "EPSG:32717")


}

\section{Supported CRS}{


EPSG:32717 (default), EPSG:4326, EPSG:32716, EPSG:32718


}

\section{Installation}{



install.packages("devtools")
devtools::install_github("ErickAngamarca/rbndb")



}

\section{Dependencies}{



httr, rvest, sf, leaflet, magrittr



}

\section{Author}{




Erick Angamarca




}
