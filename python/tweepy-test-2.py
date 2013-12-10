#!/usr/bin/env python

import tweepy

ckey = 'xxx'
csecret = 'xxx'
atoken = 'xxx'
asecret = 'xxx'

auth = tweepy.OAuthHandler(ckey, csecret)
auth.set_access_token(atoken, asecret)

api = tweepy.API(auth)

# here's where you went wrong (tried and tested), should be
#results = api.search(geocode='50,50,5mi')
# try with the following lat long
results = api.search(geocode='39.833193,-94.862794,5mi') 

for result in results:
    print result.text
    print result.location if hasattr(result, 'location') else "Undefined location"

