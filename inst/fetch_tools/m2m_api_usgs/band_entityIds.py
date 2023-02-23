
##########################################################################
#
# Ethan
# Get the entityIds for specific bands
#
#
#
#
#
#
##########################################################################

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
password = "Carp3jugulumusgs"
payload = {'username' : username, 'password' : password}    
apiKey = m2m.sendRequest(serviceUrl + "login", payload)    

minlon = -84
maxlon = -68 
minlat = 37 
maxlat = 47 

startdate = '2020-01-01'
enddate = '2020-01-31'

mincloud = 0
maxcloud = 5

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
    , 'maxResults' : 2
    , 'startingNumber' : 1
    , 'sceneFilter' : {
        'spatialFilter' : spatialFilter
        , 'acquisitionFilter' : acquisitionFilter
        , 'cloudCoverFilter' : cloudCoverFilter
    }#end sceneFilter
}#end payload

results = m2m.sendRequest(serviceUrl + "scene-search", payload, apiKey)["results"]
results
len(results)

# unwrap scenes and get entityIds
entityIds = ""
for rr in range(0,len(results)):
    print(rr)
    result = results[rr]
    print(result["entityId"])
    if entityIds == "":
        entityIds = entityIds + result["entityId"]
    else:
        entityIds = entityIds + "," + result["entityId"] 
entityIds

# TODO query download-options on entityIds
payload = {
    'datasetName' : 'landsat_ot_c2_l2'
    , 'entityIds' : entityIds
}#end payload

options = m2m.sendRequest(serviceUrl + "download-options", payload, apiKey)

secondary_downloads = pd.json_normalize(options)["secondaryDownloads"]

### init scenes.txt
scenesFile = open("/home/ethan/m2m_api/scenes.txt", "w")
scenesFile.write("landsat_ot_c2_l2|entityId\n")

### unrwap download options and append band entityId to scene.txt
for sd in range(0, len(secondary_downloads)):
    print(sd)
    ids = pd.DataFrame(secondary_downloads[sd])#["entityId"]
    ### take only the bands we need for evi, lswi
    ids = ids[ids["entityId"].str.contains("SR_B2|SR_B4|SR_B5|SR_B6") ]#end ids []
    ids = pd.DataFrame(ids["entityId"]).drop_duplicates().to_string(header = False, index = False)
    scenesFile.write(ids+"\n")

scenesFile.close()

# Logout
endpoint = "logout"  
if sendRequest(serviceUrl + endpoint, None, apiKey) == None:        
    print("Logged Out\n")
else:
    print("Logout Failed\n")  
