# Installatie van benodigde packages
# Uit te voeren indien de packages nog niet geïnstalleerd zijn
install.packages(c("rgbif", "purrr", "dplyr", "stringr", "readr"))

# Libraries laden
library(rgbif)
library(dplyr)
library(stringr)
library(purrr)
library(readr)

#--------------------
# Data inlezen
#--------------------
# Initiële data komt van DwC-A bestand verkregen van GRIIS database met reference: 
# Desmet P, Reyserhove L, Oldoni D, Groom Q, Adriaens T, Vanderhoeven S, Pagad S (2025). 
# Global Register of Introduced and Invasive Species - Belgium. 
# Version 1.15. Invasive Species Specialist Group ISSG. 
# Checklist dataset https://doi.org/10.15468/xoidmd accessed via GBIF.org.

taxon <- read.delim("taxon.txt", na.strings = c("", "NA"), quote = "", fileEncoding = "UTF-8")
distribution <- read.delim("distribution.txt", na.strings = c("", "NA"), quote = "", fileEncoding = "UTF-8")
description <- read.delim("description.txt", na.strings = c("", "NA"), quote = "", fileEncoding = "UTF-8")
speciesprofile <- read.delim("speciesprofile.txt", na.strings = c("", "NA"), quote = "", fileEncoding = "UTF-8")

# Data exploreren (optioneel, nuttig tijdens ontwikkeling)
# glimpse(taxon)
# str(taxon)
# summary(taxon)
# head(taxon)
# tail(taxon)
# colnames(taxon)
# dim(taxon)

#--------------------
# SpeciesKeys extraheren
#--------------------
taxon <- taxon %>%
  mutate(speciesKey = str_extract(taxonID, "\\d+"))

# Aantal unieke speciesKeys weergeven
aantal_speciesKeys <- length(unique(taxon$speciesKey))
print(paste("Aantal unieke speciesKeys:", aantal_speciesKeys))

#--------------------
# GBIF Data Download
#--------------------
# Gebruik Sys.getenv() om gevoelige informatie op te halen uit .Renviron bestand
gbif_user <- Sys.getenv("GBIF_USER")
gbif_pwd <- Sys.getenv("GBIF_PWD")
gbif_email <- Sys.getenv("GBIF_EMAIL")

# Species keys voor download voorbereiden
keys <- unique(taxon$speciesKey) %>% na.omit() %>% as.character()

# Download aanvraag voor alle records van de opgegeven speciesKeys voor België
download_res <- occ_download(
  pred_in("taxonKey", keys),
  pred("country", "BE"),
  pred("hasCoordinate", TRUE),
  user = gbif_user,
  pwd = gbif_pwd,
  email = gbif_email,
  format = "SIMPLE_CSV"
)

# Toon download resultaat en bewaar download key
download_key <- attr(download_res, "key")
print(paste("Download gestart met key:", download_key))

