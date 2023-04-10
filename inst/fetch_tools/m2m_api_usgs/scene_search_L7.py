
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

import m2m_api as m2m
serviceUrl = "https://m2m.cr.usgs.gov/api/api/json/stable/"

# Login
credentialsFile = "/n/home00/emanninen/vpRm/inst/fetch_tools/m2m_api_usgs/usgs_credentials.txt"
with open(credentialsFile, "r") as f:
    credentials = json.loads(json.load(f))

username = credentials["username"]
password = credentials["password"]

payload = {'username' : username, 'password' : password}    
apiKey = m2m.sendRequest(serviceUrl + "login", payload)    
print("Logged In\n")

datasetName = "landsat_etm_c2_l2"

minlon = -84.5
maxlon = -67.5 
minlat = 36 
maxlat = 48 

startdate = '2018-01-01'
#enddate = '2018-06-30'
enddate = '2022-12-31'

mincloud = 50
maxcloud = 100

maxResults = 20000

spatialFilter = {
    'filterType' : "mbr"
    , 'lowerLeft' : {'latitude' : minlat, 'longitude' : maxlon}
    , 'upperRight' : { 'latitude' : maxlat, 'longitude' : minlon}
}#end spatial filter

acquisitionFilter = {'start' : startdate, 'end' : enddate}

cloudCoverFilter = {'min' : mincloud, 'max' : maxcloud}

### get scenes
payload = {
    'datasetName' : datasetName
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
#scenesFile = open("/home/ethan/m2m_api/scenes.txt", "w")
scenesFile = open("/n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/scenes_L7.txt", "w")
scenesFile.write(datasetName + "|entityId\n")
### append entityIds to scenes.txt
for rr in range(0,len(results)):
    result = results[rr]
    ### the first one doesn't need a new line
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
