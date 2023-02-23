##############################################################
#
# Ethan
# use usgs m2m api example python functions to download specific landsat bands
# -u usgs username
# -p usgs password
# -f filetype. use bands
# -d output directory for downloads
# -s path to scenes.txt containing properly formatted entityId's (created by scene_search.py)
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
    parser.add_argument('-u', '--username', required=True, help='Username')
    parser.add_argument('-p', '--password', required=True, help='Password')
    #parser.add_argument('-f', '--filetype', required=False, choices=['bundle', 'band'], help='File types to download, "bundle" for bundle files and "band" for band files')
    parser.add_argument('-d', '--path', required=True, help='path to desired download destination')
    parser.add_argument('-s', '--scenesFile', required=True, help='path to scenes.txt')

    #path = "/home/ethan/m2m_api/test_landsat/landsat" # Fill a valid download path
    #scenesFile = '/home/ethan/m2m_api/scenes.txt'
    
    args = parser.parse_args()
    
    username = args.username
    password = args.password
    filetype = "band"
    path = args.path
    scenesFile = args.scenesFile

    print("\nRunning Scripts...\n")
    startTime = time.time()
    
    serviceUrl = "https://m2m.cr.usgs.gov/api/api/json/stable/"
    
    # Login
    # username = "bluegrisgris"
    # password = "Carp3jugulumusgs"
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
    for line in lines:        
        entityIds.append(line.strip())

    # Search scenes 
    # If you don't have a scenes text file that you can use scene-search to identify scenes you're interested in
    # https://m2m.cr.usgs.gov/api/docs/reference/#scene-search
    # payload = { 
    #             'datasetName' : '', # dataset alias
    #             'maxResults' : 10, # max results to return
    #             'startingNumber' : 1, 
    #             'sceneFilter' : {} # scene filter
    #           }
    
    # results = m2m.sendRequest(serviceUrl + "scene-search", payload, apiKey)  
    # for result in results:
    #     entityIds.append(result['entityId'])
    
    # Add scenes to a list
    listId = f"temp_{datasetName}_list" # customized list id
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
    bands = ["SR_B2", "SR_B4", "SR_B5", "SR_B6"]

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



