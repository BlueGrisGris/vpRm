import ee

### only need to do 1st time using python ee api
#ee.Authenticate() 

ee.Initialize() 
### set temporal extent
start_date = "2020-01-01"
end_date = "2020-01-31"
#end_date = "2020-12-31"

### get spatial extent of yangs slant feet
import netCDF4 as nc 
import numpy as np

stilt_dir = "/n/holylfs04/LABS/wofsy_lab/Lab/Everyone/for_Ethan/STILT_slantfoot/"
stilt_filename = stilt_dir + "stilt_slant_hb_202001021700.nc"
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

### maybe its easier to just take usa.....
### this doesn't work
#countries = ee.FeatureCollection("USDOS/LSIB_SIMPLE/2017"); 
#usa = countries.filter(ee.filter.eq("country_na","United_States"))

#:image_landsat = ee.ImageCollection("LANDSAT/LC08/C02/T1_L2").filterDate(start_date, end_date).filterBounds(roi)
image_landsat = ee.ImageCollection("LANDSAT/LE07/C02/T1_L2").filterDate(start_date, end_date).filterBounds(roi)

#landsat_composite = ee.Algorithms.Landsat.simpleComposite(**(
#    ,'collection': landsat
#    , 'asFloat': True
#    ))#end simpleComposite

import folium 

# see here for discussion of "scale" and projections # see here for discussion of "scale" and projections # see here for discussion of "scale" and projections # see here for discussion of "scale" and projections # see here for discussion of "scale" and projections # see here for discussion of "scale" and projections # see here for discussion of "scale" and projections # see here for discussion of "scale" and projections https://developers.google.com/earth-engine/guides/exporting
### this is the code ian sent, it is either deprecated or doesn't work in python api

#ee.batch.Download.ImageCollection.toDrive(image, 'landsat',
#                {scale: 30,
#                 region: roi,
#                 type: 'float'})


### TODO: think about projection
#projection = landsat.select('B2').projection().getInfo();

### ee only supports downloading single images at a time.  some people loop thru, 
if False:
    ### create export task for landsat image collection 
    task_landsat = ee.batch.Export.image.toDrive(**{
                        "image": landsat
                        , "description": "landsat_jan_test"
                        , "folder": "landsat"
                        , "scale": 30
                        , "region": roi.getInfo()['coordinates']
                     })

    ### send task 
    #task_landsat.start()
### this python package purports to handle export imagecollection
import geemap

out_dir = "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/landsat7"
geemap.ee_export_image_collection(image_landsat, out_dir)
