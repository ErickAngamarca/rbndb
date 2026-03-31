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

\section{Argumentos}{
  \describe{
    \item{scientific_name}{Nombre científico de la especie (ej. "Cedrela odorata", "Vismia baccifera")}
    \item{max_pages}{Número máximo de páginas (default 10, máx 1000)}
    \item{delay}{Delay entre requests en segundos (default 0.5)}
    \item{polygon}{Ruta a archivo shapefile/GeoJSON u objeto sf/SpatialPolygons}
    \item{crs}{Sistema de coordenadas. Opciones: "EPSG:32717" (default), "EPSG:32716", "EPSG:32718", "EPSG:4326", "EPSG:32617", "EPSG:24877", "EPSG:6248"}
    \item{output}{Formato de salida: "csv" (default) o "shp"}
    \item{map}{Si TRUE, muestra mapa interactivo (default FALSE)}
    \item{out_file}{Nombre del archivo de salida (sin extensión)}
  }
}

\section{Ejemplos de uso}{
  \preformatted{
library(rbndb)

# Descargar datos para una especie (todo Ecuador)
occ <- download_bndb("Cedrela odorata")

# Descargar datos filtrados por un archivo shapefile (CRS 32717)
occ <- download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.shp", crs = "EPSG:32717")

# Descargar datos filtrados por un archivo GeoJSON
occ <- download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.geojson", crs = "EPSG:4326")

# Descargar datos usando un objeto sf
library(sf)
poly <- st_read("ruta/al/poligono.shp")
occ <- download_bndb("Cedrela odorata", polygon = poly, crs = "EPSG:32717")

# Guardar como CSV
download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.shp", 
              output = "csv", out_file = "datos")

# Guardar como Shapefile (requiere especificar CRS)
download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.shp", 
              output = "shp", out_file = "datos", crs = "EPSG:32717")

# Ver en mapa interactivo (requiere especificar CRS)
download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.shp", map = TRUE, crs = "EPSG:4326")

# Especificar sistema de coordenadas WGS84
occ <- download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.shp", 
                     crs = "EPSG:4326")

# Especificar sistema de coordenadas UTM (para Ecuador)
occ <- download_bndb("Cedrela odorata", polygon = "ruta/al/poligono.shp", 
                     crs = "EPSG:32717")
  }
}

\section{Sistemas de coordenadas soportados (crs)}{
  \describe{
    \item{EPSG:32717}{WGS 84 / UTM zone 17S - DEFAULT, apropiado para Ecuador}
    \item{EPSG:32716}{WGS 84 / UTM zone 16S}
    \item{EPSG:32718}{WGS 84 / UTM zone 18S}
    \item{EPSG:4326}{WGS 84 (latitud/longitud)}
    \item{EPSG:32617}{WGS 84 / UTM zone 17N}
    \item{EPSG:32618}{WGS 84 / UTM zone 18N}
    \item{EPSG:32714}{WGS 84 / UTM zone 14S}
    \item{EPSG:32715}{WGS 84 / UTM zone 15S}
    \item{EPSG:32713}{WGS 84 / UTM zone 13S}
    \item{EPSG:6248}{SIRGAS 2000 / UTM zone 17S}
    \item{EPSG:6247}{SIRGAS 2000 / UTM zone 16S}
    \item{EPSG:24877}{PSAD 56 / UTM zone 17S (sistema histórico)}
    \item{EPSG:24878}{PSAD 56 / UTM zone 18S}
    \item{EPSG:24876}{PSAD 56 / UTM zone 16S}
    \item{EPSG:4248}{PSAD 56 (geográfico)}
    \item{EPSG:4269}{NAD 27 (geográfico)}
  }
}

\section{Formato de salida (output)}{
  \describe{
    \item{csv}{Guarda datos en archivo CSV (formato tabular)}
    \item{shp}{Guarda datos en shapefile (formato espacial). Requiere especificar crs}
  }
}

\section{Requisitos}{
  \itemize{
    \item Si output = "shp", debe especificar crs
    \item Si map = TRUE, debe especificar crs
    \item El CRS debe ser compatible con las coordenadas del polígono
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
    \item magrittr
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
