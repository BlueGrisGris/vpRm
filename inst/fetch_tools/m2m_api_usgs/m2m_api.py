
# =============================================================================
#  USGS/EROS Inventory Service Example
#  Description: Download Landsat Collection 2 files
#  Usage: python download_sample.py -u username -p password -f filetype
#         optional argument f refers to filetype including 'bundle' or 'band'
# =============================================================================

import json
import requests
import sys
import time
import argparse
import re
import threading
import datetime

maxthreads = 8 # Threads count for downloads
sema = threading.Semaphore(value=maxthreads)

# Send http request
def sendRequest(url, data, apiKey = None, exitIfNoResponse = True):  
    json_data = json.dumps(data)
    
    if apiKey == None:
        response = requests.post(url, json_data)
    else:
        headers = {'X-Auth-Token': apiKey}              
        response = requests.post(url, json_data, headers = headers)  
    
    try:
      httpStatusCode = response.status_code 
      if response == None:
          print("No output from service")
          if exitIfNoResponse: sys.exit()
          else: return False
      output = json.loads(response.text)
      if output['errorCode'] != None:
          print(output['errorCode'], "- ", output['errorMessage'])
          if exitIfNoResponse: sys.exit()
          else: return False
      if  httpStatusCode == 404:
          print("404 Not Found")
          if exitIfNoResponse: sys.exit()
          else: return False
      elif httpStatusCode == 401: 
          print("401 Unauthorized")
          if exitIfNoResponse: sys.exit()
          else: return False
      elif httpStatusCode == 400:
          print("Error Code", httpStatusCode)
          if exitIfNoResponse: sys.exit()
          else: return False
    except Exception as e: 
          response.close()
          print(e)
          if exitIfNoResponse: sys.exit()
          else: return False
    response.close()
    
    return output['data']

def downloadFile(url, path):
    sema.acquire()
    try:        
        response = requests.get(url, stream=True)
        disposition = response.headers['content-disposition']
        filename = re.findall("filename=(.+)", disposition)[0].strip("\"")
        print(f"Downloading {filename} ...\n")
        if path != "" and path[-1] != "/":
            filename = "/" + filename
        open(path+filename, 'wb').write(response.content)
        print(f"Downloaded {filename}\n")
        sema.release()
    except Exception as e:
        print(f"Failed to download from {url}. Will try to re-download.")
        sema.release()
        runDownload(threads, url)
    
def runDownload(threads, url, path):
    thread = threading.Thread(target=downloadFile, args=(url,path))
    threads.append(thread)
    thread.start()
