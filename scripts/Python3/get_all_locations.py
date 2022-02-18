
import requests
import json
 
url = 'https://data.oceannetworks.ca/api/locations'
parameters = {'method':'getTree',
			'token':'YOUR_TOKEN_HERE', # replace YOUR_TOKEN_HERE with your personal token obtained from the 'Web Services API' tab at https://data.oceannetworks.can/Profile when logged in.
			'locationCode':'MOBP'}
 
response = requests.get(url,params=parameters)
 
if (response.ok):
	print('Locations')
	locations = json.loads(str(response.content,'utf-8'))
	for location in locations:
		locationCode = location['locationCode']
		locationName = location['locationName']
		children = location['children']
		print('{0} - {1}'.format(locationCode,locationName))

		if (children):
			for child in children:
				getLocationChild(child,2)
else:
	if(response.status_code == 400):
		error = json.loads(str(response.content,'utf-8'))
		print(error) # json response contains a list of errors, with an errorMessage and parameter
	else:
		print ('Error {} - {}'.format(response.status_code,response.reason))
 
 
def getLocationChild(location,level):
	locationCode = location['locationCode']
	locationName = location['locationName']
	children = location['children']
	sTab = "  ".join(["" for r in range(0,level)])
	print('{0}{1} - {2}'.format(sTab,locationCode,locationName))
 
	if (children):
		for child in children:
			getLocationChild(child,level+1)
