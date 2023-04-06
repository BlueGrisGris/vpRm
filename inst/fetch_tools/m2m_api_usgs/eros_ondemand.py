
# coding: utf-8

# # ESPA-API DEMO code
# 
# Since many of our services written in python also interact with the API, we have
# this example as a quick run-through which should hopefully get anyone started
# towards building their own simple python services capable of interacting
# with ESPA.
# 
# ## Official documentation:
# * See the [ESPA API Source Code](https://github.com/USGS-EROS/espa-api/)
# * Visit the [ESPA On-Demand Interface](https://espa.cr.usgs.gov)
# 
# For questions regarding this source code, or the ESPA project, please use the
# [Landsat Contact Us](https://landsat.usgs.gov/contact) page and specify
# **USGS ESPA** in the "Subject" section.
# 
# ### WARNING! _This example is only provided as is._
# 
# ---
# 
# ---

# In[1]:

import platform
print(platform.python_version())


# ## Dependencies
# We will use the [requests](http://docs.python-requests.org/en/master/)
# library, although similar operations are available through the
# [Standard Python Libraries](https://docs.python.org/2/library/internet.html)

# In[2]:

import requests
import json
import getpass


# The current URL hosting the ESPA interfaces has reached a stable version 1.0

# In[3]:

host = 'https://espa.cr.usgs.gov/api/v1/'


# ESPA uses the ERS credentials for identifying users

# In[5]:

username = 'bluegrisgris'
password = getpass.getpass()


# ---
# 
# ---

# ## espa_api: A Function
# First and foremost, define a simple function for interacting with the API. 
# 
# The key things to watch for:
# 
# * Always scrub for a `"messages"` field returned in the response, it is only informational about a request
#   * **Errors** (`"errors"`): Brief exlaination about why a request failed
#   * **Warnings** (`"warnings"`): Cautions about a successful response
# * Always make sure the requested HTTP `status_code` returned is valid 
#   * **GET**: `200 OK`: The requested resource was successfully fetched (result can still be empty)
#   * **POST**: `201 Created`: The requested resource was created
#   * **PUT**: `202 Accepted`: The requested resource was updated

# In[6]:

def espa_api(endpoint, verb='get', body=None, uauth=None):
    """ Suggested simple way to interact with the ESPA JSON REST API """
    auth_tup = uauth if uauth else (username, password)
    response = getattr(requests, verb)(host + endpoint, auth=auth_tup, json=body)
    print('{} {}'.format(response.status_code, response.reason))
    data = response.json()
    if isinstance(data, dict):
        messages = data.pop("messages", None)  
        if messages:
            print((json.dumps(messages, indent=4)))
    try:
        response.raise_for_status()
    except Exception as e:
        print(e)
        return None
    else:
        return data


# ## General Interactions: Authentication
# Basic call to get the current user's information. It requires valid credentials, and is a good check that the system is available

# In[7]:

print('GET /api/v1/user')
resp = espa_api('user')
print((json.dumps(resp, indent=4)))


# Here, we can see what an error response will look like:

# In[9]:

print('GET /api/v1/user')
espa_api('user', uauth=('invalid', 'invalid'))


# ## General Interactions: Available Options
# 
# ESPA offers several services, descriptions can be found here: 
# * [AVAILABLE-PRODUCTS](/docs/available-products.md)
# * [CUSTOMIZATION](/docs/customization.md)

# Call to demonstrate what is returned from available-products

# In[10]:

print('GET /api/v1/available-products')
avail_list = {'inputs': ['LE07_L1TP_029030_20170221_20170319_01_T1',
                         'MOD09A1.A2017073.h10v04.006.2017082160945.hdf',
                         #'bad_scene_id'  # <-- Note: Unrecognized ID
                        ]
             }
resp = espa_api('available-products', body=avail_list)
print(json.dumps(resp, indent=4))


# ESPA can produce outputs all of the same geographic projections.  
# 
# Call to show the available projection parameters that can be used:

# In[11]:

print('GET /api/v1/projections')
projs = espa_api('projections')
print(json.dumps(list(projs.keys())))


# This is a Schema Definition, useful for building a valid order
# 
# Example (*UTM Projection*):

# In[12]:

print(json.dumps(projs['utm']['properties'], indent=4))


# ### More resources about the API
# 
# For further reading: 
# 
# * [API-REQUIREMENTS](/docs/api-requirements.md)
# * [API-RESOURCES-LIST](/docs/api-resources-list.md)
# * [Product Flow](/docs/product_flow.txt)
# * [TERMS](/docs/terms.md)
# 
# ---
# 
# ---

# ## Practical Example: Building An Order
# Here we use two different Landsat sensors to build up an order, and then place the order into the system

# In[13]:

l8_ls = ['LC08_L1TP_029030_20161109_20170219_01_T1',
         'LC08_L1TP_029030_20160821_20170222_01_T1',
         'LC08_L1TP_029030_20130712_20170309_01_T1']
l7_ls =['LE07_L1TP_029030_20170221_20170319_01_T1',
        'LE07_L1TP_029030_20161101_20161127_01_T1',
        'LE07_L1TP_029030_20130602_20160908_01_T1']

# Differing products across the sensors
l7_prods = ['toa', 'bt']
l8_prods = ['sr']

# Standard Albers CONUS
projection = {'aea': {'standard_parallel_1': 29.5,
                      'standard_parallel_2': 45.5,
                      'central_meridian': -96.0,
                      'latitude_of_origin': 23.0,
                      'false_easting': 0,
                      'false_northing': 0,
                      'datum': 'nad83'}}

# Let available-products place the acquisitions under their respective sensors
ls = l8_ls + l7_ls

print('GET /api/v1/available-products')
order = espa_api('available-products', body=dict(inputs=ls))
print((json.dumps(order, indent=4)))


# **NOTE**: Here we will not need to know what the sensor names were for the Product IDs, thanks to the response from this `available-products` resource. 

# In[14]:

# Replace the available products that was returned with what we want
for sensor in order.keys():
    if isinstance(order[sensor], dict) and order[sensor].get('inputs'):
        if set(l7_ls) & set(order[sensor]['inputs']):
            order[sensor]['products'] = l7_prods
        if set(l8_ls) & set(order[sensor]['inputs']):
            order[sensor]['products'] = l8_prods

# Add in the rest of the order information
order['projection'] = projection
order['format'] = 'gtiff'
order['resampling_method'] = 'cc'
order['note'] = 'API Demo Jupyter!!'

# Notice how it has changed from the original call available-products
print((json.dumps(order, indent=4)))


# #### Place the order

# In[21]:

# Place the order
print('POST /api/v1/order')
resp = espa_api('order', verb='post', body=order)
print((json.dumps(resp, indent=4)))


# If successful, we will get our order-id

# In[22]:

orderid = resp['orderid']


# ## Check the status of an order
# 

# In[23]:

print(('GET /api/v1/order-status/{}'.format(orderid)))
resp = espa_api('order-status/{}'.format(orderid))
print((json.dumps(resp, indent=4)))


# Now, we can check for any completed products, and get the download url's for completed scenes

# In[24]:

print(('GET /api/v1/item-status/{0}'.format(orderid)))
resp = espa_api('item-status/{0}'.format(orderid), body={'status': 'complete'})
print((json.dumps(resp[orderid], indent=4)))


# In[25]:

# Once the order is completed or partially completed, can get the download url's
for item in resp[orderid]:
    print(("URL: {0}".format(item.get('product_dload_url'))))


# # Find previous orders 
# 
# List backlog orders for the authenticated user.

# In[26]:

print('GET /api/v1/list-orders')
filters = {"status": ["complete", "ordered"]}  # Here, we ignore any purged orders
resp = espa_api('list-orders', body=filters)
print((json.dumps(resp, indent=4)))


# ## Emergency halt an Order
# ### PLEASE BE CAREFUL!
# 
# ESPA processes your orders in the sequence in which they are recieved.  
# You may want to remove blocking orders in your queue, to prioritize your latest orders

# In[27]:

# In-process orders
print('GET /api/v1/list-orders')
filters = {"status": ["ordered"]}
orders = espa_api('list-orders', body=filters)

# Here we cancel an incomplete order
orderid = orders[0]
cancel_request = {"orderid": orderid, "status": "cancelled"}
print('PUT /api/v1/order')
order_status = espa_api('order', verb='put', body=cancel_request)

print((json.dumps(order_status, indent=4)))


# # Python Script
# 
# This notebook is available as a script for [download here](/examples/api_demo.py).
