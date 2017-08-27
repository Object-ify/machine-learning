import tweepy
from textblob import TextBlob

consumer_key = '***'
consumer_secret = '***'
access_token = '***'
access_token_secret = '***'

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

api = tweepy.API(auth)

public_tweets = api.search('Star wars')

for tweet in public_tweets:
	print(tweet.text.encode('utf-8'))
	analysis = TextBlob(tweet.text)
	print(analysis.sentiment)
