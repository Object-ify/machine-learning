Let’s create a simple tweets sentiment analyzer in python.

First of all, you need to get your twitter apps credentials in way to grab the tweets, go to https://apps.twitter.com

After that, you should have your consumer key, consumer secret, access token, and access token secret.

And finally, let’s come out with some code, but before make sure you already have the tweepy and textblob libraries installed at your machine:

pip install tweepy

pip install textblob

Run the file above: tweets-sentiment-analyzer.py

Basically, the output will show the tweet and a sentiment object with two fields: polarity and subjectivity.

Polarity: It measures how negative ot positive the tweet is: (-1 to +1).
Subjectivity: It measures the text subjectiveness. -1 is objective, 1 is subjective: (-1 to +1).

You may change the text for anything you want, or even put the text as an input parameter.

Enjoy it.
