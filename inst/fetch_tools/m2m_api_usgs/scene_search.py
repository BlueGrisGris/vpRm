
# The entityIds/displayIds need to save to a text file such as scenes.txt.
# The header of text file should follow the format: datasetName|displayId or datasetName|entityId. 
# sample file - scenes.txt
# landsat_ot_c2_l2|displayId
# LC08_L2SP_012025_20201231_20210308_02_T1
# LC08_L2SP_012027_20201215_20210314_02_T1

import json
import requests
import sys
import time
import argparse
import re
import threading
import datetime

import pandas as pd

import test_landsat as m2m
serviceUrl = "https://m2m.cr.usgs.gov/api/api/json/stable/"

# Login
username = "bluegrisgris"
***REMOVED***payload = {'username' : username, 'password' : password}    
apiKey = m2m.sendRequest(serviceUrl + "login", payload)    
print("Logged In\n")

minlon = -84
maxlon = -68 
minlat = 37 
maxlat = 47 

startdate = '2020-01-01'
enddate = '2020-01-31'

mincloud = 0
maxcloud = 10

maxResults = 5000

spatialFilter = {
    'filterType' : "mbr"
    , 'lowerLeft' : {'latitude' : minlat, 'longitude' : maxlon}
    , 'upperRight' : { 'latitude' : maxlat, 'longitude' : minlon}
}#end spatial filter

acquisitionFilter = {'start' : startdate, 'end' : enddate}

cloudCoverFilter = {'min' : mincloud, 'max' : maxcloud}

### get scenes
payload = {
    'datasetName' : 'landsat_ot_c2_l2'
    , 'maxResults' : maxResults
    , 'startingNumber' : 1
    , 'sceneFilter' : {
        'spatialFilter' : spatialFilter
        , 'acquisitionFilter' : acquisitionFilter
        , 'cloudCoverFilter' : cloudCoverFilter
    }#end sceneFilter
}#end payload

results = m2m.sendRequest(serviceUrl + "scene-search", payload, apiKey)["results"]

### init scenes.txt
scenesFile = open("/home/ethan/m2m_api/scenes.txt", "w")
scenesFile.write("landsat_ot_c2_l2|entityId\n")
# append entityIds to scenes.txt
for rr in range(0,len(results)):
    #print(rr)
    result = results[rr]
    #print(result["entityId"])
    if rr == 0:
        scenesFile.write(result["entityId"])
    else:
        scenesFile.write("\n" + result["entityId"])

scenesFile.close()

print(f"{len(results)} scenes")

# Logout
endpoint = "logout"  
if m2m.sendRequest(serviceUrl + endpoint, None, apiKey) == None:        
    print("Logged Out\n")
else:
    print("Logout Failed\n")  
