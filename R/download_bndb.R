#' Download occurrence data from BNDB Ecuador
#'
#' @param scientific_name Scientific name of the species
#' @param max_pages Maximum number of pages to download (default 10)
#' @param delay Delay between requests in seconds (default 0.5)
#' @param polygon SpatialPolygonsDataFrame, sf object, or file path to shapefile/GeoJSON.
#'   If NULL, downloads all Ecuador. Can be a file path (e.g., "path/to/polygon.shp" or 
#'   "path/to/polygon.geojson") or an R object (sf/SpatialPolygons).
#' @param crs Coordinate reference system for output (default "EPSG:32717").
#'   Required if output = "shp" or map = TRUE. Common options:
#'   - "EPSG:32717" - UTM zone 17S (default, appropriate for Ecuador)
#'   - "EPSG:4326" - WGS84 (latitude/longitude)
#' @param output Output format: "csv" or "shp" (default "csv")
#' @param map If TRUE, display interactive map with leaflet (default FALSE).
#'   Requires crs to be specified.
#' @param out_file Output filename without extension (if NULL, returns object in R)
#' @return Data frame with occurrence data
#' @export
#' @importFrom httr GET
#' @importFrom rvest read_html html_text html_nodes html_attr
#' @importFrom sf st_as_sf st_transform st_intersection st_read st_write st_crs
#' @importFrom leaflet leaflet addTiles addMarkers addPolygons
#' @importFrom magrittr %>%
#' @examples
#' \dontrun{
#' # Download all records for a species (all Ecuador)
#' occ <- download_bndb("Vismia baccifera")
#'
#' # Download records filtered by a shapefile (WGS84)
#' occ <- download_bndb("Vismia baccifera", polygon = "path/to/polygon.shp", crs = "EPSG:4326")
#'
#' # Save as CSV
#' download_bndb("Vismia baccifera", polygon = "path/to/polygon.shp", 
#'               output = "csv", out_file = "data")
#'
#' # Save as shapefile in UTM
#' download_bndb("Vismia baccifera", polygon = "path/to/polygon.shp", 
#'               output = "shp", out_file = "data", crs = "EPSG:32717")
#'
#' # Display interactive map (requires crs)
#' download_bndb("Vismia baccifera", polygon = "path/to/polygon.shp", 
#'               map = TRUE, crs = "EPSG:4326")
#' }

download_bndb <- function(scientific_name,
                          max_pages = 10,
                          delay = 0.5,
                          polygon = NULL,
                          crs = "EPSG:32717",
                          output = "csv",
                          map = FALSE,
                          out_file = NULL) {

  if (output == "shp" && is.null(crs)) {
    stop("CRS must be specified when output = 'shp'. Use crs = 'EPSG:32717' or crs = 'EPSG:4326'")
  }
  
  if (map && is.null(crs)) {
    stop("CRS must be specified when map = TRUE. Use crs = 'EPSG:32717' or crs = 'EPSG:4326'")
  }
  
  if (is.null(crs)) {
    crs <- "EPSG:4326"
  }

  message("Starting BNDB download for: ", scientific_name)

  all_occurrences <- data.frame()

  base_url <- "https://bndb.sisbioecuador.bio/bndb/collections/list.php"

  for (page in 1:max_pages) {
    url <- paste0(base_url, "?taxa=", utils::URLencode(scientific_name),
                  "&taxontype=2&page=", page)

    tryCatch({
      pg <- rvest::read_html(url)

      occ_ids <- rvest::html_attr(rvest::html_nodes(pg, 'input[name="occid[]"]'), 'value')

      if (length(occ_ids) == 0) {
        message("No more records on page ", page)
        break
      }

      message("Page ", page, ": ", length(occ_ids), " records")

      for (i in seq_along(occ_ids)) {
        occ_id <- occ_ids[i]
        Sys.sleep(delay)

        occ_url <- paste0("https://bndb.sisbioecuador.bio/bndb/collections/individual/index.php?occid=", occ_id)

        tryCatch({
          occ_pg <- rvest::read_html(occ_url)
          body_text <- rvest::html_text(rvest::html_node(occ_pg, 'body'))

          extractor_simple <- function(inicio, fin) {
            pattern <- paste0(inicio, ".*?", fin)
            match <- regmatches(body_text, regexec(pattern, body_text))[[1]]
            if (length(match) == 0) return(NA)
            valor <- sub(inicio, "", match[1])
            gsub("^[[:space:]]+|[[:space:]]+$", "", valor)
          }

          lat <- NA
          lon <- NA

          coord_pattern <- "-[0-9]+\\.[0-9]+.*WGS"
          matches <- gregexpr(coord_pattern, body_text, perl = TRUE)
          regm <- matches[[1]]

          if (regm[1] > 0) {
            txt <- substr(body_text, regm[1], regm[1] + 30)
            nums <- strsplit(txt, '[^0-9.-]')[[1]]
            nums <- nums[nchar(nums) > 0]
            nums <- nums[!is.na(suppressWarnings(as.numeric(nums)))]
            if (length(nums) >= 2) {
              lat <- as.numeric(nums[1])
              lon <- as.numeric(nums[2])
            }
          }

          elev <- NA
          elev_pattern <- "Elevation:([0-9]+)"
          elev_match <- regmatches(body_text, regexec(elev_pattern, body_text))[[1]]
          if (length(elev_match) > 1) {
            elev <- as.numeric(elev_match[2])
          }

          registro <- data.frame(
            occurrenceID = occ_id,
            scientificName = scientific_name,
            taxon = extractor_simple("Taxon:", "\n"),
            family = extractor_simple("Family:", "\n"),
            catalogNumber = extractor_simple("Catalog #:", "\n"),
            recordedBy = extractor_simple("Collector:", "\n"),
            recordNumber = extractor_simple("Number:", "\n"),
            eventDate = extractor_simple("Date:", "Verbatim"),
            verbatimEventDate = extractor_simple("Verbatim Date:", "\n"),
            locality = extractor_simple("Locality:", "\n"),
            decimalLatitude = lat,
            decimalLongitude = lon,
            verbatimCoordinates = extractor_simple("Verbatim Coordinates:", "\n"),
            georeferenceRemarks = extractor_simple("Location Remarks:", "\n"),
            minimumElevationInMeters = elev,
            maximumElevationInMeters = elev,
            habitat = extractor_simple("Habitat:", "\n"),
            occurrenceRemarks = extractor_simple("Description:", "\n"),
            disposition = extractor_simple("Disposition:", "\n"),
            identifiedBy = extractor_simple("Determiner:", "\n"),
            rightsHolder = extractor_simple("Rights Holder:", "\n"),
            accessRights = extractor_simple("Access Rights:", "\n"),
            basisOfRecord = "HumanObservation",
            stringsAsFactors = FALSE
          )

          if (!is.na(registro$decimalLatitude) && !is.na(registro$decimalLongitude)) {
            all_occurrences <- rbind(all_occurrences, registro)
          }

        }, error = function(e) { })

        if (i %% 10 == 0) message("  Processed ", i, "/", length(occ_ids))
      }

    }, error = function(e) {
      message("Error on page ", page, ": ", e$message)
      break
    })
  }

  if (nrow(all_occurrences) > 0) {
    all_occurrences <- all_occurrences[!duplicated(
      paste(all_occurrences$decimalLatitude, all_occurrences$decimalLongitude)
    ), ]
  }

  message("Download complete. Total records with coordinates: ", nrow(all_occurrences))

  if (nrow(all_occurrences) == 0) {
    message("No records found.")
    return(NULL)
  }

  if (!is.null(polygon)) {
    message("Applying spatial filter...")

    if (is.character(polygon)) {
      message("Reading polygon from file: ", polygon)
      filter_region <- sf::st_read(polygon, quiet = TRUE)
    } else {
      filter_region <- polygon
    }

    if (inherits(filter_region, "SpatialPolygons")) {
      filter_region <- sf::st_as_sf(filter_region)
    }

    polygon_crs <- sf::st_crs(filter_region)
    
    if (is.null(crs)) {
      crs <- "EPSG:4326"
    }
    
    filter_region <- sf::st_transform(filter_region, crs = crs)

    message("Filtering points by polygon...")

    occ_sf <- sf::st_as_sf(all_occurrences,
                          coords = c("decimalLongitude", "decimalLatitude"),
                          crs = 4326)

    occ_sf <- sf::st_transform(occ_sf, crs = crs)

    occ_filtered <- sf::st_intersection(occ_sf, filter_region)

    if (nrow(occ_filtered) == 0) {
      message("No records found within the specified polygon")
      return(NULL)
    }

    all_occurrences <- as.data.frame(occ_filtered)
    all_occurrences <- all_occurrences[, !names(all_occurrences) %in% c("geometry")]
    all_occurrences$decimalLatitude <- sf::st_coordinates(occ_filtered)[, 2]
    all_occurrences$decimalLongitude <- sf::st_coordinates(occ_filtered)[, 1]

    message("Filtered to ", nrow(all_occurrences), " records within polygon")
  }

  if (!is.null(crs)) {
    occ_sf <- sf::st_as_sf(all_occurrences,
                          coords = c("decimalLongitude", "decimalLatitude"),
                          crs = 4326)
    occ_sf <- sf::st_transform(occ_sf, crs = crs)
    all_occurrences$decimalLatitude <- sf::st_coordinates(occ_sf)[, 2]
    all_occurrences$decimalLongitude <- sf::st_coordinates(occ_sf)[, 1]
  }

  if (!is.null(out_file)) {
    if (output == "shp") {
      occ_sf <- sf::st_as_sf(all_occurrences,
                            coords = c("decimalLongitude", "decimalLatitude"),
                            crs = crs)
      if (!grepl("\\.shp$", out_file)) {
        out_file <- paste0(out_file, ".shp")
      }
      sf::st_write(occ_sf, out_file, delete_dsn = TRUE)
      message("Saved to: ", out_file)
    } else if (output == "csv") {
      if (!grepl("\\.csv$", out_file)) {
        out_file <- paste0(out_file, ".csv")
      }
      write.csv(all_occurrences, out_file, row.names = FALSE)
      message("Saved to: ", out_file)
    }
  }

  if (map) {
    message("Generating map...")

    if (is.null(crs)) {
      crs <- "EPSG:4326"
    }

    occ_sf <- sf::st_as_sf(all_occurrences,
                          coords = c("decimalLongitude", "decimalLatitude"),
                          crs = crs)

    if (!is.null(polygon)) {
      if (exists("filter_region")) {
        polygon_map <- filter_region
      } else {
        if (is.character(polygon)) {
          polygon_map <- sf::st_read(polygon, quiet = TRUE)
        } else {
          polygon_map <- polygon
        }
        if (inherits(polygon_map, "SpatialPolygons")) {
          polygon_map <- sf::st_as_sf(polygon_map)
        }
        polygon_map <- sf::st_transform(polygon_map, crs = crs)
      }
      
      leaflet_map <- leaflet::leaflet() %>%
        leaflet::addTiles() %>%
        leaflet::addPolygons(data = polygon_map, fillColor = "blue", fillOpacity = 0.2, color = "blue", weight = 2) %>%
        leaflet::addMarkers(data = occ_sf, popup = ~paste0("<b>", scientificName, "</b><br>",
                                                           "Locality: ", locality))
    } else {
      leaflet_map <- leaflet::leaflet() %>%
        leaflet::addTiles() %>%
        leaflet::addMarkers(data = occ_sf, popup = ~paste0("<b>", scientificName, "</b><br>",
                                                           "Locality: ", locality))
    }

    message("Displaying map...")
    print(leaflet_map)
  }

  message("Done!")
  return(all_occurrences)
}
