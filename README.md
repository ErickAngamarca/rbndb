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

# Download data for a species (all Ecuador)
occ <- download_bndb("Cedrela odorata")

# Download filtered by shapefile (CRS 32717)
occ <- download_bndb("Cedrela odorata", polygon = "path/to/polygon.shp", crs = "EPSG:32717")

# Download filtered by GeoJSON
occ <- download_bndb("Cedrela odorata", polygon = "path/to/polygon.geojson", crs = "EPSG:4326")

# Download using sf object
library(sf)
poly <- st_read("path/to/polygon.shp")
occ <- download_bndb("Cedrela odorata", polygon = poly, crs = "EPSG:32717")

# Save as CSV
download_bndb("Cedrela odorata", polygon = "path/to/polygon.shp", 
              output = "csv", out_file = "data")

# Save as Shapefile (requires CRS)
download_bndb("Cedrela odorata", polygon = "path/to/polygon.shp", 
              output = "shp", out_file = "data", crs = "EPSG:32717")

# Display interactive map (requires CRS)
download_bndb("Cedrela odorata", polygon = "path/to/polygon.shp", map = TRUE, crs = "EPSG:4326")

# Use WGS84 coordinates
occ <- download_bndb("Cedrela odorata", polygon = "path/to/polygon.shp", crs = "EPSG:4326")

# Use UTM coordinates (for Ecuador)
occ <- download_bndb("Cedrela odorata", polygon = "path/to/polygon.shp", crs = "EPSG:32717")

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
| `crs` | character | Coordinate system (default "EPSG:32717") | Yes for output="shp" or map=TRUE |
| `output` | character | Output format: "csv" or "shp" (default "csv") | No |
| `map` | logical | If TRUE, display interactive leaflet map (default FALSE) | No |
| `out_file` | character | Output filename (without extension) | No |

### Coordinate System (crs)

The `crs` parameter accepts any valid EPSG code. Common options for Ecuador:

| CRS | Name | Recommended Use |
|-----|------|-----------------|
| `EPSG:32717` | WGS 84 / UTM zone 17S | **Default** - for Ecuador mainland |
| `EPSG:4326` | WGS 84 | Geographic (lat/lon) |
| `EPSG:32617` | WGS 84 / UTM zone 17N | UTM north |
| `EPSG:24877` | PSAD 56 / UTM zone 17S | Historical system |

### Requirements

- **If `output = "shp"`**: You must specify `crs`
- **If `map = TRUE`**: You must specify `crs`

### Polygon Format

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

## Interactive Map

When `map = TRUE`, an interactive leaflet map is displayed showing:
- Occurrence points with popup containing species information
- The filtering polygon (if specified)

## Notes

- The package uses web scraping to obtain data from BNDB
- Only downloads records with valid coordinates
- Removes duplicates based on coordinates
- Respects delay between requests to avoid overloading the server

## Dependencies

The package requires the following libraries:
- httr
- rvest
- sf
- leaflet
- magrittr

## Author

Erick Angamarca (erick.angamarca97@gmail.com)

## References

- Banco Nacional de Datos de Biodiversidad (BNDB): https://bndb.sisbioecuador.bio
- GADM: https://gadm.org
- EPSG: https://epsg.org
