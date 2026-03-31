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

 DESCRIPTION{
  Downloads occurrence data from the Banco Nacional de Datos de Biodiversidad (BNDB) 
  of Ecuador using web scraping. Allows spatial filtering by any custom polygon 
  provided by the user.
}

\arguments{
  \item{scientific_name}{Character. Scientific name of the species to search for.
    Example: "Cedrela odorata", "Vismia baccifera"}

  \item{max_pages}{Numeric. Maximum number of pages to download (default 10, max 1000 records).
    Each page contains up to 100 records.}

  \item{delay}{Numeric. Delay in seconds between HTTP requests (default 0.5).
    Increase this value if you experience connection errors.}

  \item{polygon}{Character or sf/SpatialPolygons. Polygonal boundary for spatial filtering.
    Can be:
    \itemize{
      \item File path to shapefile: "data/shape.shp"
      \item File path to GeoJSON: "data/shape.geojson"
      \item sf object loaded in R
      \item SpatialPolygons object from sp package
    }
    If NULL, downloads all Ecuador records.}

  \item{crs}{Character. Coordinate Reference System for output. Default is "EPSG:32717".
    Required if output = "shp" or map = TRUE. Supported CRS codes:
    \itemize{
      \item EPSG:32717 - UTM zone 17S (DEFAULT, for Ecuador)
      \item EPSG:4326 - WGS84 (lat/lon)
      \item EPSG:32716 - UTM zone 16S
      \item EPSG:32718 - UTM zone 18S
      \item EPSG:32617 - UTM zone 17N
      \item EPSG:24877 - PSAD 56 / UTM zone 17S
      \item EPSG:6248 - SIRGAS 2000 / UTM zone 17S
    }}

  \item{output}{Character. Output format. Options:
    \itemize{
      \item "csv" (default) - Saves as CSV file (tabular format)
      \item "shp" - Saves as shapefile (spatial format). Requires crs to be specified.
    }}

  \item{map}{Logical. If TRUE, displays an interactive map with leaflet showing occurrence points.
    Default is FALSE. Requires crs to be specified.}

  \item{out_file}{Character. Output filename without extension.
    If not provided (NULL), returns data frame in R without saving to file.
    Extension is added automatically if not present.}
}

\value{
  Returns a data frame with occurrence records containing Darwin Core fields:
  occurrenceID, scientificName, taxon, family, catalogNumber, recordedBy, recordNumber,
  eventDate, verbatimEventDate, locality, decimalLatitude, decimalLongitude,
  verbatimCoordinates, georeferenceRemarks, minimumElevationInMeters,
  maximumElevationInMeters, habitat, occurrenceRemarks, disposition, identifiedBy,
  rightsHolder, accessRights, basisOfRecord
}

\examples{
\dontrun{
# Download all records for a species (all Ecuador)
occ <- download_bndb("Cedrela odorata")

# Download with shapefile filter (requires CRS)
occ <- download_bndb("Cedrela odorata", polygon = "data/shape.shp", crs = "EPSG:32717")

# Download with GeoJSON filter
occ <- download_bndb("Cedrela odorata", polygon = "data/shape.geojson", crs = "EPSG:4326")

# Save as CSV
download_bndb("Cedrela odorata", polygon = "data/shape.shp", 
              output = "csv", out_file = "data")

# Save as Shapefile (requires CRS)
download_bndb("Cedrela odorata", polygon = "data/shape.shp", 
              output = "shp", out_file = "data", crs = "EPSG:32717")

# Display interactive map (requires CRS)
download_bndb("Cedrela odorata", polygon = "data/shape.shp", 
              map = TRUE, crs = "EPSG:4326")

# Use WGS84 coordinates
occ <- download_bndb("Cedrela odorata", crs = "EPSG:4326")

# Use PSAD 56 (historical system)
occ <- download_bndb("Cedrela odorata", crs = "EPSG:24877")
}
}

\keyword{package}
\keyword{Web scraping}
