##############################################################
#
# Ethan
# use usgs m2m api example python functions to download specific landsat bands
# -u usgs username
# -p usgs password
# -d output directory for downloads
# -s path to scenes.txt containing properly formatted entityId's (created by scene_search.py)
# -is start_index of scenes in scenes.txt to download
# -ie end_index of scenes in scenes.txt to download
#
##############################################################

import json
import requests
import sys
import time
import argparse
import re
import threading
import datetime

import m2m_api as m2m

label = datetime.datetime.now().strftime("%Y%m%d_%H%M%S") # Customized label using date time
threads = []

if __name__ == '__main__':     
    # User input    
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--username', required=False, help='Username')
    parser.add_argument('-p', '--password', required=False, help='Password')
    parser.add_argument('-c', '--credentialsFile', required=False, help='path to usgs_credentials file')
    #parser.add_argument('-f', '--filetype', required=False, choices=['bundle', 'band'], help='File types to download, "bundle" for bundle files and "band" for band files')
    parser.add_argument('-d', '--path', required=True, help='path to desired download destination')
    parser.add_argument('-s', '--scenesFile', required=True, help='path to scenes.txt')
    parser.add_argument('-is', '--index_start', required=False, help='start index of scenes in scenes.txt to download')
    parser.add_argument('-ie', '--index_end', required=False, help='end index of scenes in scenes.txt to download')

    args = parser.parse_args()
    
    username = args.username
    password = args.password
    credentialsFile = args.credentialsFile

    if username == None or password == None:
        if credentialsFile == None:
            raise ValueError("Provide either both -u and -p options or -c for usgs login")
        with open(credentialsFile, "r") as f:
            credentials = json.loads(json.load(f))

        username = credentials["username"]
        password = credentials["password"]

    path = args.path
    scenesFile = args.scenesFile
    index_start = args.index_start
    index_end = args.index_end

    scene_index_bool = False
    ### if both start and end indexes were given, only take those scenes
    if index_start is not None or index_end is not None:
        ###  need both indices
        if index_start is None or index_end is None:
            raise ValueError("if one scene index is provided, both must be")
        scene_index_bool = True
        index_start = int(index_start)
        index_end = int(index_end)

    print("\nRunning Scripts...\n")
    startTime = time.time()
    
    serviceUrl = "https://m2m.cr.usgs.gov/api/api/json/stable/"
    
    # Login
    payload = {'username' : username, 'password' : password}    
    apiKey = m2m.sendRequest(serviceUrl + "login", payload)    
    print("API Key: " + apiKey + "\n")
    
    # Read scenes
    f = open(scenesFile, "r")
    lines = f.readlines()   
    f.close()
    header = lines[0].strip()
    datasetName = header[:header.find("|")]
    idField = header[header.find("|")+1:]
    
    print("Scenes details:")
    print(f"Dataset name: {datasetName}")
    print(f"Id field: {idField}\n")

    entityIds = []
    
    lines.pop(0)
    ### if scene indices are provided, only download those ones
    if scene_index_bool: 
    ### dont index past the total number of scenes
        if index_start > len(lines) - 1:
            raise ValueError(f"start_index > number of scenes in {scenesFile}")
        if index_end > len(lines) - 1:
            print(f"toobig:{index_end}")
            index_end = len(lines) - 1
            print(f"replaced:{index_end}")
        print(f"indices: {lines[index_start:index_end]}")
        for line in lines[index_start:index_end]:        
            entityIds.append(line.strip())
    else:
        for line in lines:        
            entityIds.append(line.strip())

    # Add scenes to a list
    listId = f"temp_{datasetName}_list_{index_start}_{index_end}" # customized list id
    payload = {
        "listId": listId,
        'idField' : idField,
        "entityIds": entityIds,
        "datasetName": datasetName
    }
    
    print("Adding scenes to list...\n")
    count = m2m.sendRequest(serviceUrl + "scene-list-add", payload, apiKey)    
    print("Added", count, "scenes\n")

    # Get download options
    payload = {
        "listId": listId,
        "datasetName": datasetName
    }
      
    print("Getting product download options...\n")
    products = m2m.sendRequest(serviceUrl + "download-options", payload, apiKey)
    print("Got product download options\n")
    
    ### select which landsat bands you want w regex against entityIds
    ### different bands for 7 vs 8
    if datasetName == "landsat_ot_c2_l2":
        bands = ["SR_B2", "SR_B4", "SR_B5", "SR_B6", "SR_CLOUD_QA"]
    if datasetName == "landsat_etm_c2_l2":
        bands = ["SR_B1", "SR_B3", "SR_B4", "SR_B5", "SR_CLOUD_QA"]

    # Select products
    downloads = []
    # select band files
    for product in products: 
        if product["secondaryDownloads"] is not None and len(product["secondaryDownloads"]) > 0:
            for secondaryDownload in product["secondaryDownloads"]:
                ### only take bulk downloadable entityIds
                ### and filter for the landsat bands you want!
                if secondaryDownload["bulkAvailable"] and any(band in secondaryDownload["entityId"] for band in bands):
                    # print(secondaryDownload["entityId"])
                    downloads.append({"entityId":secondaryDownload["entityId"], "productId":secondaryDownload["id"]})
    
    # Remove the list
    payload = {
        "listId": listId
    }
    m2m.sendRequest(serviceUrl + "scene-list-remove", payload, apiKey)                
    

    # Send download-request
    payload = {
        "downloads": downloads,
        "label": label,
        'returnAvailable': True
    }#end payLoad
    
    print(f"Sending download request ...\n")
    results = m2m.sendRequest(serviceUrl + "download-request", payload, apiKey)
    print(f"Done sending download request\n") 

      
    for result in results['availableDownloads']:       
        print(f"Get download url: {result['url']}\n" )
        m2m.runDownload(threads, result['url'], path)

    preparingDownloadCount = len(results['preparingDownloads'])
    preparingDownloadIds = []
    if preparingDownloadCount > 0:
        for result in results['preparingDownloads']:  
            preparingDownloadIds.append(result['downloadId'])
  
        payload = {"label" : label}                
        # Retrieve download urls
        print("Retrieving download urls...\n")
        results = m2m.sendRequest(serviceUrl + "download-retrieve", payload, apiKey, False)
        if results != False:
            for result in results['available']:
                if result['downloadId'] in preparingDownloadIds:
                    preparingDownloadIds.remove(result['downloadId'])
                    print(f"Get download url: {result['url']}\n" )
                    m2m.runDownload(threads, result['url'], path)
                
            for result in results['requested']:   
                if result['downloadId'] in preparingDownloadIds:
                    preparingDownloadIds.remove(result['downloadId'])
                    print(f"Get download url: {result['url']}\n" )
                    m2m.runDownload(threads, result['url'], path)
        
        # Don't get all download urls, retrieve again after 30 seconds
        while len(preparingDownloadIds) > 0: 
            print(f"{len(preparingDownloadIds)} downloads are not available yet. Waiting for 30s to retrieve again\n")
            time.sleep(30)
            results = m2m.sendRequest(serviceUrl + "download-retrieve", payload, apiKey, False)
            if results != False:
                for result in results['available']:                            
                    if result['downloadId'] in preparingDownloadIds:
                        preparingDownloadIds.remove(result['downloadId'])
                        print(f"Get download url: {result['url']}\n" )
                        m2m.runDownload(threads, result['url'], path)
    
    print("\nGot download urls for all downloads\n")                
    # Logout
    endpoint = "logout"  
    if m2m.sendRequest(serviceUrl + endpoint, None, apiKey) == None:        
        print("Logged Out\n")
    else:
        print("Logout Failed\n")  
     
    print("Downloading files... Please do not close the program\n")
    for thread in threads:
        thread.join()
            
    print("Complete Downloading")
    
    executionTime = round((time.time() - startTime), 2)
    print(f'Total time: {executionTime} seconds')
