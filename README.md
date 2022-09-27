# vpRm
## Version 0.0.0.9002 "Thuja plicata"

<!-- badges: start -->
[![R-CMD-check](https://github.com/BlueGrisGris/vpRm/workflows/R-CMD-check/badge.svg)](https://github.com/BlueGrisGris/vpRm/actions)
<!-- badges: end -->

# Introduction

VPRM (Vegetation Photosynthesis Respiration Model) is a model of NEE (Net Ecosystem Exchange) (Mahadevan et al 2008).  This R package handles the driver data and calculations to run a VPRM model

## Goals
This package should:
- Provide a single wrapper function to run VPRM within CONUS (eventually global).
- Be modular and tolerant of different sources/forms for driver data.  If a new source for driver data is desired, it should be possible to slot in a new script for importing that data with minimal reconfiguration of the rest of the code. 
- Be semi-robust. I am a grad student, and this is one part of my research, but it should be useful to people with different computer systems than me within a reasonable amount of work.

# Getting Started
This package is not yet hosted on CRAN.  In order to install, if the R package `devtools` is not installed, install it:
``` 
Rscript -e 'install.packages("devtools")'
```

Then, clone this repository:

```
git clone https://github.com/BlueGrisGris/vpRm.git
```

Then, navigate into the vpRm directory, and call `install()` from devtools to install the package into your library. 

```
cd vpRm
Rscript -e 'devtools::install()'
```
This will install the `vpRm` package.  Now, to begin running VPRM models, the following driver data are required, and can be downloaded from a variety of sources:
- Photosynthetically Available Radiation (PAR) or Downwelling Shortwave Radiation (SDR)
- Temperature at 2 meters above the surface
- Enhanced Vegetation Index (EVI)
- Landcover type
- Greenup and Greendown days for each pixel 
- Minimum and Maximum EVI data for the year (Or a full year's worth of EVI data)

To initialize an object of class `vpRm` in R, supply the filenames of your driver data to the `new_vpRm()` function:

```R
my_vpRm <- new_vpRm(
	vpRm_dir
	, lc_dir
	, isa_dir
	, temp_dir
	, par_dir
	, evi_dir
	, evi_extrema_dir
	, green_dir
)
```
Next, process the driver data:
```R
proc_drivers(my_vpRm)
```
Finally, run the model:
```R
run(my_vpRm)
```

# Version Information 
## Version 0.0.0.9002 "Thuja plicata"

## Version 0.0.0.9001 "Ficus rubiginosa"
- Implement simple interface to run VPRM over a predetermined spatial-temporal domain (for example, a STILT output)
- Implement processing 2D and 3D driver data to a format that can be fed into a VPRM model
- Implement S3 class "vpRm", along with methods to:
	+ Process all driver data
	+ Run a VPRM model

## Version 0.0.0.9000 "Picea pungens"
- No minimum viable soluton

## Goals for next version:
- Manage driver time data in a smooth way: easy assignment/not
- Handle multiple years per run
## Goals for future versions:
- Simple R/vpRm interface for downloading driver data 
- Wrapper function to run VPRM models in a single line
