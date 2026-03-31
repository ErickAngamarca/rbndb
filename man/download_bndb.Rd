\name{download_bndb}
\alias{download_bndb}
\title{download_bndb: Download occurrence data from BNDB Ecuador}
\usage{
download_bndb(scientific_name,
              max_pages = 10,
              delay = 0.5,
              polygon = NULL,
              crs = "EPSG:32717",
              output = "csv",
              map = FALSE,
              out_file = NULL)
}

 ARGUMENTS{
  \itemize{
    \item{\code{scientific_name}}{: Character. Scientific name of the species to search for. 
      Must be a valid binomial name (e.g., "Vismia baccifera", "Cedrela odorata").}

    \item{\code{max_pages}}{: Numeric. Maximum number of pages to download from BNDB. 
      Each page contains up to 100 records. Default is 10 (max 1000 records).}

    \item{\code{delay}}{: Numeric. Delay in seconds between HTTP requests to avoid 
      overloading the BNDB server. Default is 0.5 seconds. Increase this value if 
      you experience connection errors.}

    \item{\code{polygon}}{: Character or sf/SpatialPolygons object. Polygonal boundary 
      for spatial filtering. Can be:
      \itemize{
        \item File path to a shapefile (e.g., "path/to/polygon.shp")
        \item File path to a GeoJSON file (e.g., "path/to/polygon.geojson")
        \item An sf object loaded in R
        \item A SpatialPolygons object from the sp package
      }
      If NULL, downloads all records from Ecuador. The polygon should be in a 
      projected coordinate system or WGS84 (EPSG:4326) for correct spatial filtering.}

    \item{\code{crs}}{: Character. Coordinate Reference System (CRS) for the output 
      data. Default is "EPSG:32717" (WGS 84 / UTM zone 17S, appropriate for Ecuador).
      The following CRS options are supported:
      \itemize{
        \item "EPSG:32717" - WGS 84 / UTM zone 17S (DEFAULT - appropriate for Ecuador)
        \item "EPSG:32716" - WGS 84 / UTM zone 16S
        \item "EPSG:32718" - WGS 84 / UTM zone 18S
        \item "EPSG:4326" - WGS 84 (latitude/longitude) - Geographic system
        \item "EPSG:32617" - WGS 84 / UTM zone 17N
        \item "EPSG:32618" - WGS 84 / UTM zone 18N
        \item "EPSG:32714" - WGS 84 / UTM zone 14S
        \item "EPSG:32715" - WGS 84 / UTM zone 15S
        \item "EPSG:32713" - WGS 84 / UTM zone 13S
        \item "EPSG:6248" - SIRGAS 2000 / UTM zone 17S
        \item "EPSG:6247" - SIRGAS 2000 / UTM zone 16S
        \item "EPSG:24877" - PSAD 56 / UTM zone 17S (old Ecuador system)
        \item "EPSG:24878" - PSAD 56 / UTM zone 18S
        \item "EPSG:24876" - PSAD 56 / UTM zone 16S
        \item "EPSG:4248" - PSAD 56 (geographic)
        \item "EPSG:4269" - NAD 27 (geographic)
        \item "EPSG:26717" - NAD 27 / UTM zone 17N
      }
      You can also use any valid PROJ4 string or EPSG code. 
      Note: This parameter transforms the coordinates in the output data frame 
      (decimalLatitude/decimalLongitude columns).}

    \item{\code{output}}{: Character. Output format. Options:
      \itemize{
        \item "csv" (default) - Returns data frame and optionally saves to CSV
        \item "shp" - Returns data frame and optionally saves to shapefile
      }}

    \item{\code{map}}{: Logical. If TRUE, displays an interactive map using leaflet 
      showing the occurrence points and (optionally) the filtering polygon. 
      Default is FALSE. The map opens in the RStudio Viewer or default browser.}

    \item{\code{out_file}}{: Character. Output filename without extension. 
      If specified, saves the data to a file:
      \itemize{
        \item If output = "csv": saves to "filename.csv"
        \item If output = "shp": saves to multiple shapefile components (filename.shp, 
              filename.shx, filename.dbf, etc.)
      }
      If NULL (default), returns the data frame in R without saving to file.}
  }
}

 DESCRIPTION{
  Downloads occurrence data from the Banco Nacional de Datos de Biodiversidad (BNDB) 
  of Ecuador using web scraping. Allows spatial filtering by any custom polygon 
  provided by the user.
}

 DETAILS{
  The function performs the following steps:
  \enumerate{
    \item Connects to the BNDB website and searches for the specified species
    \item Downloads occurrence records page by page
    \item Extracts coordinates and other metadata from each record
    \item Optionally filters points by the provided polygon using spatial intersection
    \item Transforms coordinates to the specified CRS
    \item Optionally saves output to file or displays interactive map
  }

  Spatial filtering: If a polygon is provided, the function uses \code{sf::st_intersection} 
  to clip points to the polygon boundary. Only records with coordinates falling 
  within the polygon are retained.

  CRS transformation: The input coordinates from BNDB are in WGS84 (EPSG:4326). 
  If a different CRS is specified, coordinates are transformed using \code{sf::st_transform}.

  About Ecuador CRS: Ecuador has used several coordinate reference systems historically:
  \itemize{
    \item WGS84 (EPSG:4326) - Current standard, used by GPS and GNSS
    \item UTM zones 17S/18S (EPSG:32717/32718) - Most common for Ecuador mainland
    \item SIRGAS 2000 - Modern reference system for Latin America
    \item PSAD 56 - Older system still used in some historical data
  }
}

 EXAMPLES{
  \dontrun{
  # Download all records for a species (all Ecuador)
  occ <- download_bndb("Vismia baccifera")

  # Download with custom polygon (shapefile path)
  occ <- download_bndb("Vismia baccifera", polygon = "data/provincias/loja.shp")

  # Download with GeoJSON polygon
  occ <- download_bndb("Vismia baccifera", polygon = "data/loja.geojson")

  # Save as CSV
  download_bndb("Vismia baccifera", polygon = "data/loja.shp", 
                output = "csv", out_file = "loja_data")

  # Save as Shapefile
  download_bndb("Vismia baccifera", polygon = "data/loja.shp", 
                output = "shp", out_file = "loja_data")

  # Display interactive map
  download_bndb("Vismia baccifera", polygon = "data/loja.shp", map = TRUE)

  # Use WGS84 coordinates (latitude/longitude)
  occ <- download_bndb("Vismia baccifera", polygon = "data/loja.shp", 
                       crs = "EPSG:4326")

  # Use UTM zone 17N
  occ <- download_bndb("Vismia baccifera", polygon = "data/loja.shp", 
                       crs = "EPSG:32617")

  # Use PSAD 56 (historical data)
  occ <- download_bndb("Vismia baccifera", polygon = "data/loja.shp", 
                       crs = "EPSG:24877")

  # Download from multiple pages
  occ <- download_bndb("Cedrela odorata", max_pages = 20, delay = 1)
  }
}

 VALUE{
  Returns a data frame with occurrence records containing the following columns:
  \itemize{
    \item occurrenceID
    \item scientificName
    \item taxon
    \item family
    \item catalogNumber
    \item recordedBy
    \item recordNumber
    \item eventDate
    \item verbatimEventDate
    \item locality
    \item decimalLatitude
    \item decimalLongitude
    \item verbatimCoordinates
    \item georeferenceRemarks
    \item minimumElevationInMeters
    \item maximumElevationInMeters
    \item habitat
    \item occurrenceRemarks
    \item disposition
    \item identifiedBy
    \item rightsHolder
    \item accessRights
    \item basisOfRecord
  }

  If \code{out_file} is specified, returns NULL invisibly after saving the file.
  If \code{map = TRUE}, displays an interactive leaflet map.
}

\keyword{package}
\keyword{Web scraping}
\keyword{Biodiversidad}
\keyword{Ecuador}
\keyword{Spatial filtering}
\keyword{CRS}
