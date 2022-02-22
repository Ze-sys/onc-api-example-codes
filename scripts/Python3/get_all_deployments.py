
import requests
import json

url = 'https://data.oceannetworks.ca/api/deployments'
parameters = {'method':'get',
			'token':'YOUR_TOKEN_HERE', # replace YOUR_TOKEN_HERE with your personal token obtained from the 'Web Services API' tab at https://data.oceannetworks.ca/Profile when logged in.
			'locationCode':'BACAX',
			'propertyCode':'seawatertemperature',
			'dateFrom':'2010-07-01T00:00:00.000Z',
			'dateTo':'2011-06-30T23:59:59.999Z'}

response = requests.get(url,params=parameters)

if (response.ok):
	deployments = json.loads(str(response.content,'utf-8')) # convert the json response to an object
	for deployment in deployments:
		print(deployment)
else:
	if(response.status_code == 400):
		error = json.loads(str(response.content,'utf-8'))
		print(error) # json response contains a list of errors, with an errorMessage and parameter
	else:
		print ('Error {} - {}'.format(response.status_code,response.reason))
