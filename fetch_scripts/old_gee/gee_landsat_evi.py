
import ee

### only need to do 1st time using python ee api
#ee.Authenticate() 

### dirty workaround for ee damage:
### https://github.com/google/earthengine-api/issues/181
import collections
collections.Callable = collections.abc.Callable

ee.Initialize() 
### set temporal extent
start_date = "2020-01-01"
end_date = "2020-01-31"
#end_date = "2020-12-31"

### get spatial extent of yangs slant feet
import netCDF4 as nc 
import numpy as np

stilt_dir = "/Users/ethan/Desktop/research/vpRm/inst/test_data/stilt_test/by-id/01"
stilt_filename = stilt_dir + "/01_foot.nc"
stilt = nc.Dataset(stilt_filename) 
#foot = stilt["foot"]

print(f'max lon {np.max(stilt["lon"])}')
print(f'min lon {np.min(stilt["lon"])}')
print(f'max lat {np.min(stilt["lat"])}')
print(f'min lat {np.max(stilt["lat"])}')

lon_max = np.max(stilt["lon"])
lon_min = np.min(stilt["lon"])
lat_max = np.max(stilt["lat"])
lat_min = np.min(stilt["lat"])

roi = ee.Geometry.Rectangle(lon_min, lat_min, lon_max, lat_max)
### still don't understand how this is
region = roi.buffer(1000)

evi = ee.ImageCollection("LANDSAT/LC08/C01/T1_8DAY_EVI")\
        .filterDate(start_date, end_date)\
        .filterBounds(roi)\
        .select("EVI")

# |%%--%%| <NONE|NONE>

import geemap
colorizedVis = {
  min: 0.0,
  max: 1.0,
  "palette": [
    'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718', '74A901',
    '66A000', '529400', '3E8601', '207401', '056201', '004C00', '023B01',
    '012E01', '011D01', '011301'
  ],
}
mm = geemap.Map()
mm.addLayer(evi, colorizedVis)

# |%%--%%| <NONE|kAzJIRXXwT>

mm

# |%%--%%| <kAzJIRXXwT|NONE>

#out_dir = "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/landsat7"
out_dir = "landsat_evi"

geemap.ee_export_image_collection(evi, out_dir, region = region)
