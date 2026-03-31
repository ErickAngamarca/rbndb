\name{download_bndb}
\alias{download_bndb}
\title{download_bndb: Download occurrence data from BNDB Ecuador}
\usage{
download_bndb(scientific_name,
              max_pages = 10,
              delay = 0.5,
              province = NULL,
              canton = NULL,
              parish = NULL,
              crs = "EPSG:32717",
              output = "csv",
              map = FALSE,
              out_file = NULL)
}

 ARGUMENTS{
  \itemize{
    \item{\code{scientific_name}}{: Character. Scientific name of the species to search for.}

    \item{\code{max_pages}}{: Numeric. Maximum number of pages to download (default 10).}

    \item{\code{delay}}{: Numeric. Delay between requests in seconds (default 0.5).}

    \item{\code{province}}{: Character. Province name (GADM level 1). If NULL, downloads all Ecuador.
      Use \code{NULL} for entire country. Use \code{province = "Loja"} for example.}

    \item{\code{canton}}{: Character. Canton name (GADM level 2). Requires province to be specified.}

    \item{\code{parish}}{: Character. Parish name (GADM level 3). Requires canton to be specified.}

    \item{\code{crs}}{: Character. Coordinate reference system (default "EPSG:32717").}

    \item{\code{output}}{: Character. Output format: "csv" or "shp" (default "csv").}

    \item{\code{map}}{: Logical. If TRUE, display interactive map with leaflet (default FALSE).}

    \item{\code{out_file}}{: Character. Output filename without extension.
      If NULL, returns data frame in R.}
  }
}

 DESCRIPTION{
  Downloads occurrence data from the Banco Nacional de Datos de Biodiversidad (BNDB)
  of Ecuador using web scraping. Allows spatial filtering by province, canton, or parish
  using GADM administrative boundaries.
}

 DETAILS{
  The function downloads occurrence records from the BNDB website and optionally filters
  them by administrative boundaries. It uses GADM data to define the spatial extent.

  Spatial filtering hierarchy:
  \itemize{
    \item If \code{parish} is specified, filters by parish (GADM level 3)
    \item If only \code{canton} is specified, filters by canton (GADM level 2)
    \item If only \code{province} is specified, filters by province (GADM level 1)
    \item If all are NULL, returns all Ecuador records
  }

  If an invalid name is provided, the function will display available options.
}

 EXAMPLES{
  \dontrun{
  # Download all records for a species (all Ecuador)
  occ <- download_bndb("Vismia baccifera")

  # Download records for a specific province
  occ <- download_bndb("Vismia baccifera", province = "Loja")

  # Download records for a specific canton
  occ <- download_bndb("Vismia baccifera", province = "Loja", canton = "Loja")

  # Download records for a specific parish
  occ <- download_bndb("Vismia baccifera", province = "Loja", canton = "Loja", parish = "San Sebastian")

  # Save as shapefile
  download_bndb("Vismia baccifera", province = "Loja", output = "shp", out_file = "data")

  # Save as CSV
  download_bndb("Vismia baccifera", province = "Loja", output = "csv", out_file = "data")

  # Display interactive map
  download_bndb("Vismia baccifera", map = TRUE)

  # Use different CRS
  download_bndb("Vismia baccifera", province = "Loja", crs = "EPSG:4326")
  }
}

 VALUE{
  Returns a data frame with occurrence records. If \code{out_file} is specified,
  saves the data to a file and returns NULL invisibly.
  If \code{map = TRUE}, displays an interactive leaflet map.
}

\keyword{package}
\keyword{Web scraping}
\keyword{Biodiversidad}
\keyword{Ecuador}
