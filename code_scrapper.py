import os
import json
import bs4 as bs
import requests
'''
For api example codes documentation. Ref DATA-5283
'''

script_dirs = ['scripts/Python3', 'scripts/R', 'scripts/MATLAB'] # Forget pyhon 2.x

# create a folder for each language if it does not exist
[os.makedirs(x) for x in script_dirs if not os.path.exists(x)]

def write_to_file(file_name, data):
    with open(file_name, 'w') as f:
        f.write(data)


def notify(method_name,language_name,script_path):
        success_ = 'Example code for method {} and language option {} saved in `{}` file.'.format(method_name,
                                                                                              language_name,
                                                                                              script_path)
        return print(success_)

def parse_and_write_out_example_code(obj):
    """
    This function parses the example code from the wiki page.
    INPUT:
    obj: soup object
    OUTPUT:
    Writes the example code to a file with the  a filename based on api method used and language extension.
    """
    method_names = obj.find_all('span', class_="expand-control-text")
    language_names = obj.find_all('div', class_="codeHeader panelHeader pdl")
    language_examples = obj.find_all('div', class_="codeContent panelContent pdl")
    print('------------------------------------------------------')
    print(len(method_names), len(language_names), len(language_examples))

    for methd_name in method_names:
        
        for language_name, language_example in zip(language_names, language_examples): 
            if  methd_name.text != 'Expand source':
                method_name = methd_name.text.lower().replace(' ', '_')
                language_name = language_name.text.replace(' ', '').strip('.x')
                language_example = language_example.text

                if language_name.lower() == 'python3':
                    script_path = 'scripts/{}/{}.py'.format(language_name, method_name)
                    write_to_file(script_path, language_example)
                    notify(method_name,language_name,script_path)

                elif language_name == 'R':
                    script_path = 'scripts/{}/{}.R'.format(language_name, method_name)
                    write_to_file(script_path, language_example)
                    notify(method_name,language_name,script_path)

                elif language_name == 'MATLAB':
                    script_path = 'scripts/{}/{}.m'.format(language_name, method_name)
                    write_to_file(script_path, language_example)
                    notify(method_name,language_name,script_path)

                else:
                    print(method_name,language_name,script_path)
                    raise Exception('This is all Greek to me \U0001F3B2')

 # parse and write out each discovery method  example code for each language

def get_all_discovery_service_codes(discover_urls):
    for url in discover_urls:
        response = requests.get(url)
        if response.ok:
            requestInfo = response._content  
            soup1 = bs.BeautifulSoup(requestInfo, 'html.parser')
            parse_and_write_out_example_code(soup1)
        else:
            if response.status_code == 400:
                error = response._content
                print(error)  
            else:
                print('Error {} - {}'.format(response.status_code, response.reason))

# parse and write out each request method  example code for each language
def get_all_request_service_codes(request_urls, all_request_codes = []):
    for url in request_urls:
        response = requests.get(url)
        if response.ok:
            requestInfo = response._content
            soup2 = bs.BeautifulSoup(requestInfo, 'html.parser')
            parse_and_write_out_example_code(soup2)
        else:
            if response.status_code == 400:
                error = response._content
                print(error)
            else:
                print('Error {} - {}'.format(response.status_code, response.reason))

def make_requests(url):
        response = requests.get(url)

        if response.ok:
            requestInfo = response._content
        else:
            if (response.status_code == 400):
                error = json.loads(str(response._content, 'utf-8'))
                print(error)
            else:
                print('Error {} - {}'.format(response.status_code, response.reason))

        # Parse the html file using BeautifulSoup
        soup = bs.BeautifulSoup(requestInfo, 'html.parser')
        request_hrfs = soup.select("a[href*='display/O2A/Request']")
        discover_hrfs = soup.select("a[href*='display/O2A/Discover']")
        discover_urls = ['https://wiki.oceannetworks.ca' + hrf.get('href') for hrf in discover_hrfs]
        request_urls = ['https://wiki.oceannetworks.ca' + hrf.get('href') for hrf in request_hrfs]
        return discover_urls, request_urls

if __name__ == '__main__':
    # Grab the html file that has the Sample Codes
    url = f'https://wiki.oceannetworks.ca/display/O2A/Sample+Code'
    discover_urls, request_urls = make_requests(url)       
    get_all_discovery_service_codes(discover_urls)
    get_all_request_service_codes(request_urls)

# TODO: scrap the client library example codes next. Low priority. 
