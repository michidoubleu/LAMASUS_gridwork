# LAMASUS_gridwork
Repo to manage files for the grid work related to the LAMASUS-downscaling gridwork


# Explaination of files within the codes subfolder

## LAMASUS_NUTS_EEAref_mapping.R
This code performs a countrywise mapping of the EEA reference grid (1km² pixel) to the LAMASUS NUTS regions.
As an input it uses the LAMASUS NUTS geometries, to be found at: https://zenodo.org/records/10990809 and the EEA reference grid with 1 square-kilometer resolution, to be found at: https://www.eea.europa.eu/en/datahub/datahubitem-view/3c362237-daa4-45e2-8c16-aaadfb1a003b.

## EEAref_EEAbiogeo_mapping.R
This code performs a countrywise mapping of the EEA reference grid (1km² pixel) to the EEA biogeographical regions.
As an input it uses the spatial information about the biogeographical regions of Europe, to be found at: https://www.eea.europa.eu/en/datahub/datahubitem-view/11db8d14-f167-4cd5-9205-95638dfd9618 and the EEA reference grid with 1 square-kilometer resolution, to be found at: https://www.eea.europa.eu/en/datahub/datahubitem-view/3c362237-daa4-45e2-8c16-aaadfb1a003b.