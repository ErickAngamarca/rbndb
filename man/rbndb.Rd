\docType{package}
\name{rbndb}
\alias{rbndb}
\title{rbndb: Download Data from BNDB Ecuador}

 DESCRIPTION{
  Paquete R para descargar datos de ocurrencia del Banco Nacional
  de Datos de Biodiversidad (BNDB) de Ecuador mediante web scraping.
  Permite filtrar datos por cualquier polígono espacial definido por el usuario.
}

\section{Funciones}{
  \itemize{
    \item \code{\link{download_bndb}}: Descarga datos de ocurrencia del BNDB
      con opciones de filtrado espacial mediante polígono personalizado.
  }
}

\section{Ejemplos de uso}{
  \preformatted{
library(rbndb)

# Descargar datos para una especie (todo Ecuador)
occ <- download_bndb("Vismia baccifera")

# Descargar datos filtrados por un archivo shapefile
occ <- download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.shp")

# Descargar datos filtrados por un archivo GeoJSON
occ <- download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.geojson")

# Descargar datos usando un objeto sf
library(sf)
poly <- st_read("ruta/al/poligono.shp")
occ <- download_bndb("Vismia baccifera", polygon = poly)

# Guardar como CSV
download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.shp", 
              output = "csv", out_file = "datos")

# Guardar como Shapefile
download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.shp", 
              output = "shp", out_file = "datos")

# Ver en mapa interactivo
download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.shp", map = TRUE)

# Especificar sistema de coordenadas (WGS84)
occ <- download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.shp", 
                     crs = "EPSG:4326")

# Especificar sistema de coordenadas (PSAD 56 - sistema histórico)
occ <- download_bndb("Vismia baccifera", polygon = "ruta/al/poligono.shp", 
                     crs = "EPSG:24877")
  }
}

\section{Sistemas de coordenadas soportados}{
  El paquete soporta múltiples sistemas de coordenadas:
  \itemize{
    \item EPSG:32717 - UTM zona 17S (DEFAULT)
    \item EPSG:32716 - UTM zona 16S
    \item EPSG:32718 - UTM zona 18S
    \item EPSG:4326 - WGS84 (geográfico)
    \item EPSG:32617 - UTM zona 17N
    \item EPSG:24877 - PSAD 56 / UTM zona 17S
    \item EPSG:6248 - SIRGAS 2000 / UTM zona 17S
    \item Cualquier otro código EPSG válido
  }
}

\section{Instalacion}{
  \preformatted{
install.packages("devtools")
devtools::install_github("ErickAngamarca/rbndb")
library(rbndb)
  }
}

\section{Dependencias}{
  El paquete requiere las siguientes librerías:
  \itemize{
    \item httr
    \item rvest
    \item sf
    \item leaflet
  }
}

\section{Autor}{
  Erick Angamarca (\email{erick.angamarca97@gmail.com})
}

\keyword{package}
\keyword{Web scraping}
\keyword{Biodiversidad}
\keyword{Ecuador}
\keyword{Coordinate systems}

\references{
  Banco Nacional de Datos de Biodiversidad (BNDB) - Ecuador
  \url{https://bndb.sisbioecuador.bio}

  GADM: \url{https://gadm.org}
  
  EPSG: \url{https://epsg.org}
}
