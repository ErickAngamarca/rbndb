#' Download occurrence data from BNDB Ecuador
#'
#' @param scientific_name Scientific name of the species
#' @param max_pages Maximum number of pages to download (default 10)
#' @param delay Delay between requests in seconds (default 0.5)
#' @param province Province name (GADM level 1). If NULL, downloads all Ecuador
#' @param canton Canton name (GADM level 2)
#' @param parish Parish name (GADM level 3)
#' @param crs Coordinate reference system (default "EPSG:32717")
#' @param output Output format: "csv" or "shp" (default "csv")
#' @param map If TRUE, display map with leaflet (default FALSE)
#' @param out_file Output filename without extension (if NULL, returns object in R)
#' @return Data frame or sf object with occurrence data
#' @export
#' @importFrom httr GET
#' @importFrom rvest read_html html_text html_nodes html_attr
#' @importFrom sf st_as_sf st_transform st_intersection st_write
#' @importFrom geodata gadm
#' @importFrom leaflet leaflet addTiles addMarkers addPolygons
#' @importFrom dplyr filter select
#' @examples
#' \dontrun{
#' occ <- download_bndb("Vismia baccifera")
#' occ <- download_bndb("Escallonia micrantha", province = "Loja")
#' download_bndb("Vismia baccifera", province = "Loja", output = "shp", out_file = "data")
#' download_bndb("Vismia baccifera", map = TRUE)
#' }

download_bndb <- function(scientific_name,
                          max_pages = 10,
                          delay = 0.5,
                          province = NULL,
                          canton = NULL,
                          parish = NULL,
                          crs = "EPSG:32717",
                          output = "csv",
                          map = FALSE,
                          out_file = NULL) {

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

  has_filter <- !is.null(parish) || !is.null(canton) || !is.null(province)

  if (has_filter) {
    message("Applying spatial filter...")

    if (!is.null(parish)) {
      level <- 3
      filter_name <- parish
      filter_col <- "NAME_3"
    } else if (!is.null(canton)) {
      level <- 2
      filter_name <- canton
      filter_col <- "NAME_2"
    } else {
      level <- 1
      filter_name <- province
      filter_col <- "NAME_1"
    }

    message("Loading GADM boundary data (level ", level, ")...")
    ecuador <- geodata::gadm("ECU", level = level, path = tempdir())

    available_names <- unique(ecuador[[filter_col]])

    if (!filter_name %in% available_names) {
      message("\nError: '", filter_name, "' not found.")
      message("Available ", filter_col, " options:")
      print(sort(available_names))
      stop("Invalid name. Please check the options above.")
    }

    filter_region <- ecuador[ecuador[[filter_col]] == filter_name, ]

    message("Filtering to: ", filter_name)

    occ_sf <- sf::st_as_sf(all_occurrences,
                          coords = c("decimalLongitude", "decimalLatitude"),
                          crs = 4326)

    occ_sf <- sf::st_transform(occ_sf, crs = sf::st_crs(filter_region))

    occ_filtered <- sf::st_intersection(occ_sf, filter_region)

    if (nrow(occ_filtered) == 0) {
      message("No records found within ", filter_name)
      return(NULL)
    }

    all_occurrences <- as.data.frame(occ_filtered)
    all_occurrences <- all_occurrences[, !names(all_occurrences) %in% c("geometry")]
    all_occurrences$decimalLatitude <- sf::st_coordinates(occ_filtered)[, 2]
    all_occurrences$decimalLongitude <- sf::st_coordinates(occ_filtered)[, 1]

    message("Filtered to ", nrow(all_occurrences), " records within ", filter_name)
  }

  if (crs != "EPSG:32717") {
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
                            crs = 4326)
      sf::st_write(occ_sf, paste0(out_file, ".shp"), delete_dsn = TRUE)
      message("Saved to: ", out_file, ".shp")
    } else if (output == "csv") {
      write.csv(all_occurrences, paste0(out_file, ".csv"), row.names = FALSE)
      message("Saved to: ", out_file, ".csv")
    }
  }

  if (map) {
    message("Generating map...")

    occ_sf <- sf::st_as_sf(all_occurrences,
                          coords = c("decimalLongitude", "decimalLatitude"),
                          crs = 4326)

    if (has_filter) {
      leaflet_map <- leaflet::leaflet(filter_region) %>%
        leaflet::addTiles() %>%
        leaflet::addPolygons(fillColor = "blue", fillOpacity = 0.2, color = "blue", weight = 2) %>%
        leaflet::addMarkers(data = occ_sf, popup = ~paste0("<b>", scientificName, "</b><br>",
                                                           "Locality: ", locality))
    } else {
      leaflet_map <- leaflet::leaflet(occ_sf) %>%
        leaflet::addTiles() %>%
        leaflet::addMarkers(popup = ~paste0("<b>", scientificName, "</b><br>",
                                              "Locality: ", locality))
    }

    message("Displaying map...")
    print(leaflet_map)
  }

  message("Done!")
  return(all_occurrences)
}
