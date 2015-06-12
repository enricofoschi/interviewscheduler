
*Note*: I know this guide is not top notch. I wrote it one morning in 15 mins while commuting to work. I promise I'll make it better, one day... :). If you need any information / help / customisation, I'll be happy to improve this project, so get in touch @ foschi.enrico@gmail.com. Also, pull requests are very welcome - just try to follow the same coding guidelines...  

# Interview Scheduler

Interview Scheduler is a very simple but effective app that allows HR manager to automate the process of scheduling interviews between candidates and interviewers.

It works by checking the availability of 2 or more interviewers (configurable) in their Google Calendar and then by sending the candidate a list of available slots they can choose from. 

As soon as the candidate chooses one slot, an invitation is sent to the interviewers and a notification is sent to the HR manager, so that a formal invitation to the candidate can be sent through their own internal systems (e.g. JobVite).

## Installation & Setup

* Obtain Google API Credentials to be able to use Google Calendar API
* In the API Console, enable Google Calendar API
* Change the quota of Google Calendar API to 500 requests / seconds (you'll unlikely go beyond the 5 / seconds, but we just want to increase the quota case multiple HR managers are using it)
* Clone the repo
* Rename settings.default.json to settings.json
* Set your Google API Credentials in settings.json
* Set the domain for the email addresses that will be recognized as HR Manager in /environment.coffee
* $ meteor --settings=settings.json
* Set your mailgun credentials to be able to send emails through MailGun
* http://localhost:3000/admin and you're good to go

## Deployment 

This deployment is based on an Ubuntu box on EC2, running on the free tier (it's good enough unless you have to schedule hundreds of interviews a day).

Of course you can deploy anywhere you want :)

* Install MUP
* Rename mup.sample.json to mup.json
* Get an EC2 box from Amazon - recommended to use Ubuntu as it already comes with a few basic packages out of the box
* Configure your host, urls, folders and pem key in mup.json
* $ mup setup
* $ mup deploy