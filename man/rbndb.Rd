\docType{package}
\name{rbndb}
\alias{rbndb}
\title{rbndb: Download Data from BNDB Ecuador}

 DESCRIPTION{
  Paquete R para descargar datos de ocurrencia del Banco Nacional
  de Datos de Biodiversidad (BNDB) de Ecuador mediante web scraping.
  Permite filtrar datos por provincia, canton o parroquia utilizando
  datos de GADM.
}

\section{Funciones}{
  \itemize{
    \item \code{\link{download_bndb}}: Descarga datos de ocurrencia del BNDB
      con opciones de filtrado espacial.
  }
}

\section{Ejemplos de uso}{
  \preformatted{
library(rbndb)

# Descargar datos para una especie (todo Ecuador)
occ <- download_bndb("Vismia baccifera")

# Descargar datos para una provincia especifica
occ <- download_bndb("Vismia baccifera", province = "Loja")

# Guardar como shapefile
download_bndb("Vismia baccifera", province = "Loja", output = "shp", out_file = "data")

# Ver en mapa
download_bndb("Vismia baccifera", map = TRUE)
  }
}

\section{Instalacion}{
  \preformatted{
install.packages("rbndb")
library(rbndb)
  }
}

\section{Autor}{
  Erick Angamarca (\email{erick.angamarca97@gmail.com})
}

\keyword{package}
\keyword{Web scraping}
\keyword{Biodiversidad}
\keyword{Ecuador}

\references{
  Banco Nacional de Datos de Biodiversidad (BNDB) - Ecuador
  \url{https://bndb.sisbioecuador.bio}

  GADM: \url{https://gadm.org}
}
