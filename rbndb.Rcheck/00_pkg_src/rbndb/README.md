# rbndb

R package to download occurrence data from the Banco Nacional de Datos de Biodiversidad (BNDB) of Ecuador via web scraping.

## Installation

```r
# Install from GitHub
devtools::install_github("ErickAngamarca/rbndb")

library(rbndb)
```

## Usage

```r
library(rbndb)

# Download all records for a species (raw data)
occ <- download_bndb("Cedrela odorata")

# Download with filtering (Ecuador bounds, no duplicates, no NA)
occ <- download_bndb("Cedrela odorata", filt = TRUE)

# Download filtered by a shapefile
occ <- download_bndb("Alnus acuminata", polygon = "path/to/polygon.shp")

# Save as CSV
download_bndb("Cedrela odorata", filetype = "csv", out_file = "data")

# Save as Excel
download_bndb("Cedrela odorata", filetype = "excel", out_file = "data")

# Specify number of pages
occ <- download_bndb("Cedrela odorata", max_pages = 5)
```

## Arguments

| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| `scientific_name` | character | Scientific name of species (e.g., "Cedrela odorata") | Yes |
| `max_pages` | numeric | Max pages to download (default 10) | No |
| `delay` | numeric | Delay between requests in seconds (default 0.5) | No |
| `polygon` | character/sf | Path to shapefile/GeoJSON or sf object | No |
| `filt` | logical | If TRUE, filter to Ecuador bounds, remove duplicates and NA (default FALSE) | No |
| `filetype` | character | Output format: "csv" or "excel" (default "csv") | No |
| `out_file` | character | Output filename (without extension) | No |

## Filtering

When `filt = TRUE`, the following filters are applied:
- Remove records with NA coordinates
- Remove records with zero coordinates
- Keep only records within Ecuador bounds (lat: -5 to 2, lon: -82 to -75)
- Remove duplicate coordinates

## Polygon Format

The `polygon` parameter accepts:
- Shapefile path: `"path/to/polygon.shp"`
- GeoJSON path: `"path/to/polygon.geojson"`
- sf object loaded in R
- SpatialPolygons object from sp package

The package uses `sf::st_intersection` to clip points within the polygon.

## Value

Returns a data frame with the following Darwin Core columns:

- occurrenceID
- scientificName
- taxon
- family
- catalogNumber
- recordedBy
- recordNumber
- eventDate
- verbatimEventDate
- locality
- decimalLatitude
- decimalLongitude
- verbatimCoordinates
- georeferenceRemarks
- minimumElevationInMeters
- maximumElevationInMeters
- habitat
- occurrenceRemarks
- disposition
- identifiedBy
- rightsHolder
- accessRights
- basisOfRecord

## Notes

- The package uses web scraping to obtain data from BNDB
- Only downloads records with valid coordinates
- All coordinates are in WGS84 (EPSG:4326) decimal degrees format
- Respects delay between requests to avoid overloading the server

## Dependencies

The package requires the following libraries:
- rvest
- sf
- magrittr
- openxlsx

## Author

Erick Angamarca (erick.angamarca97@gmail.com)

## References

- Banco Nacional de Datos de Biodiversidad (BNDB): https://bndb.sisbioecuador.bio
