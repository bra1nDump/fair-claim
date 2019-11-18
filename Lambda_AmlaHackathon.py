import json
import boto3
import math
from math import cos, asin, sqrt

def make_key(x):
    y = [i + '_' for i in x]
    y_str = ''
    for i in y:
        y_str = y_str + i
        
    y_str = y_str[:-1]
    return y_str
    
def deg2rad(deg):
  return deg * (math.pi/180)
    

def getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2):
    R = 6371 # Radius of the earth in km
    dLat = deg2rad(lat2-lat1) # deg2rad below
    dLon = deg2rad(lon2-lon1)
    a = math.sin(dLat/2) * math.sin(dLat/2) +\
    math.cos(deg2rad(lat1)) * math.cos(deg2rad(lat2)) * \
    math.sin(dLon/2) * math.sin(dLon/2)
    
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    d = R * c; # Distance in km
    return d


def calc_distance(lat1, lon1, lat2, lon2):
    p = 0.017453292519943295     #Pi/180
    a = 0.5 - cos((lat2 - lat1) * p)/2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2
    return 12742 * asin(sqrt(a)) #2*R*asin...

def lambda_handler(event, context):
    tmp = event
    # TODO implement
    print(tmp)
    
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table('AmlaHackathon')
    vin = event['vin'] 
    
    
    latitude = str(event['latitude'])
    longitude = str(event['longitude'])
    timestamp = str(event['timestamp'])
    vehicle_speed_mean = str(event['vehicle_speed_mean'])
    engine_speed_mean = str(event['engine_speed_mean'])
    brake_mean = str(event['brake_mean'])
    
    
    
    
    yyyy = timestamp[:4]
    mm = timestamp[5:7]
    dd = timestamp[8:10]
    hr = timestamp[11:13]
    mn = timestamp[14:16]
    sc = timestamp[17:19]
    vin_timestamp = make_key([yyyy,mm,dd,hr,mn,sc])
    timestamp_new = vin_timestamp
    vin_timestamp = vin + '_' + vin_timestamp
    print(vin_timestamp)
    
    print(latitude)
    print(type(latitude))
    response = table.put_item(
      Item={
           'vin_timestamp': vin_timestamp,
           'timestamp': timestamp_new,
           'vin':vin,
           'latitude': latitude,
           'longitude': longitude,
           'vehicle_speed_mean':vehicle_speed_mean,
           'engine_speed_mean':engine_speed_mean
       }
    )
    print("PutItem succeeded:")
    print(json.dumps(response, indent=4))
    
   

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
    