import json
import boto3
from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError
import math
def calc_distance(lat1, lon1, lat2, lon2):
    p = 0.017453292519943295     #Pi/180
    a = 0.5 - math.cos((lat2 - lat1) * p)/2 + math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2
    return 12742 * math.asin((a)**(0.5)) #2*R*asin...
  
def lambda_handler(event, context):
    dynamodb = boto3.resource("dynamodb", region_name='us-east-1')
    table    = dynamodb.Table('AmlaHackathon')
    #vin_timestamp =  "OURCW2S3YSBEM7VEZ_2019_11_18_00_49_42"
    vin      = "OURCW2S3YSBEM7VEZ"
    
    start    = '2019_11_18_15_30_27' #'2019_11_18_00_49_42'
    
    end      =  '2019_11_18_15_31_59' #'2019_11_18_00_52_03'
    
    
    try:
        responses=[]
        victim_lats=[]
        victim_lons=[]
        out_victim_lats = []
        out_victim_lons = []
        time = start
        while(True):
           vin_timestamp =  vin + '_' + start
           if time==end:
               break
           response = table.query(IndexName='timestamp-index',KeyConditionExpression=Key('timestamp').eq(time))
           victim_response = table.get_item(Key={'vin_timestamp': vin_timestamp})
           tmp_vin_timestamp =  vin + '_' + time
           tmp_victim_response = table.get_item(Key={'vin_timestamp': tmp_vin_timestamp})
           if 'Item' in tmp_victim_response.keys():
               out_victim_lats.append(tmp_victim_response['Item']['latitude'])
               out_victim_lons.append(tmp_victim_response['Item']['longitude'])
           #print('ITEM')
           #print(victim_response)
           victim_lat = victim_response['Item']['latitude']
           victim_lon = victim_response['Item']['longitude']
           victim_lats.append(victim_lat)
           victim_lons.append(victim_lon)
           responses.append(response)
           time_list = time.split('_')
           sec = time_list[-1]
           minute = time_list[-2]
           hour = time_list[-3]
           sec_new = int(sec)+1
           minute_new = minute
           hour_new = hour
           if sec_new==60:
               sec_new='00'
               minute_new = int(minute)+1
               if minute_new==60:
                   minute_new='00'
                   hour_new = int(hour)+1
                   if 0<=hour_new<=9:
                       hour_new = '0'+str(hour_new)
               elif 0<=minute_new<=9:
                   minute_new = '0'+str(minute_new)
               else:
                   minute_new = str(minute_new)
           elif 0<=sec_new<=9:
               sec_new='0'+str(sec_new)
           else:
               sec_new=str(sec_new)
           time_list[-1] = sec_new
           time_list[-2] = minute_new
           time_list[-3] = hour_new
           time = "_".join(time_list)
        """response = table.get_item(
           Key={
               'vin': vin_timestamp
           }
        )
        """
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        minute_distance = None
        attacker = None
        for i in range(len(responses)):
            for j in responses[i][u'Items']:
                if j['vin'] != vin:
                    distance = calc_distance(float(victim_lats[i]),float(victim_lons[i]),float(j['latitude']),float(j['longitude']))
                    if minute_distance==None or distance < minute_distance:
                        minute_distance = distance
                        attacker = j['vin']
                #print(json.dumps(j,indent=4))
        print("total_response",len(responses))
        print("total_lats",len(victim_lats))
        print("total_lats",len(victim_lons))
        print("attacker",attacker)
        
        time = start
        attacker_lats=[]
        attacker_lons = []
        
        while(True):
           if time==end:
               break
           attacker_vin_timestamp = attacker +'_' + time
           #attacker_response = table.get_item(Key={'vin_timestamp': attacker_vin_timestamp})
           attacker_response = table.query(KeyConditionExpression=Key('vin_timestamp').eq(attacker_vin_timestamp))
           #print(attacker_response['Items'])
           if len(attacker_response['Items']) > 0:
               #print(attacker_response['Items'][0].keys())
               if 'vin' in attacker_response['Items'][0].keys():
                   attacker_lat = attacker_response['Items'][0]['latitude']
                   attacker_long = attacker_response['Items'][0]['longitude']
                   attacker_lats.append(attacker_lat)
                   attacker_lons.append(attacker_long)
           time_list = time.split('_')
           sec = time_list[-1]
           min = time_list[-2]
           hour = time_list[-3]
           sec_new = int(sec)+1
           min_new = min
           hour_new = hour
           if sec_new==60:
               sec_new='00'
               min_new = int(min)+1
               if min_new==60:
                   min_new='00'
                   hour_new = int(hour)+1
                   if 0<=hour_new<=9:
                       hour_new = '0'+str(hour_new)
               elif 0<=min_new<=9:
                   min_new = '0'+str(min_new)
               else:
                   min_new = str(min_new)
           elif 0<=sec_new<=9:
               sec_new='0'+str(sec_new)
           else:
               sec_new=str(sec_new)
           time_list[-1] = sec_new
           time_list[-2] = min_new
           time_list[-3] = hour_new
           time = "_".join(time_list)
    
        
        item = {'victim_latitude':out_victim_lats,'victim_longitude':out_victim_lons,'attacker':attacker,'attacker_latitude':attacker_lats,'attacker_longitude':attacker_lons}
        return {
        'statusCode': 200,
        'body': json.dumps(item) #json.dumps('Hello from Lambda!')
    }