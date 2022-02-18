# onc-api-example-codes


 This repository contains copies of code exampes shown at the Ocean Networks Canada's API service home page https://wiki.oceannetworks.ca/display/O2A/Oceans+2.0+API+Home. The examples use Python 3, MATLAB and R languages. Hopefully, each filename is descriptive enough and explains what the code in it does. For more visit the documentation on the above page. The goal of this repository is to share working code examples that use the most uptodate api services ONC provides. I will update the examples regularly. One can also simply run the notebook `code_scrapper.ipynb` or its .py version in this repository and get the latest examples. The code will download all the files in the current working directory with a structure shown below:

```
└── scripts
    ├── MATLAB
    ├── Python3
    └── R
```

Although the owner is affiliated with ONC, this repository is a personal initiative. Its goal is to promote the api service to a wider community of users by providing portable boilerplate code files. 
The first step to use the api is to register for an account and obtain a token. The ONC account creation process is easy, and anyone can have one. You can follow the link https://data.oceannetworks.ca/Login?  to register.

Issues encountered while using any of the example codes in this repository should be reported at https://jira.oceannetworks.ca/servicedesk/customer/user/login?destination=portals. The python and R codes may require installing a few packages before one can use them.

No ownership is claimed other than the files `code_scrapper.ipynb`, and `code_scrapper.py`, which are provided as is and with no restrictions. I will upload the appropriate license file after consulting with the developers.

## TODO

 - Add the example codes that use the api client libraries.

## Wish list

- Build an AI supported code generator. Wouldn't it be great to type something like `get me all onc device locations` inside a little box and a code snippet pops up.