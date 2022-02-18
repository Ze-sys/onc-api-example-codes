
import requests
import json
 
url = 'https://data.oceannetworks.ca/api/properties'
parameters = {'method':'get',
			'token':'YOUR_TOKEN_HERE', # replace YOUR_TOKEN_HERE with your personal token obtained from the 'Web Services API' tab at https://data.oceannetworks.ca/Profile when logged in.
			'deviceCategoryCode':'ADCP150KHZ'}
 
response = requests.get(url,params=parameters)
 
if (response.ok):
	properties= json.loads(str(response.content,'utf-8')) # convert the json response to an object
	for property in properties:
		print(property)
else:
	if(response.status_code == 400):
		error = json.loads(str(response.content,'utf-8'))
		print(error) # json response contains a list of errors, with an errorMessage and parameter
	else:
		print ('Error {} - {}'.format(response.status_code,response.reason))
