#*****************************************************************************
#*																			 *
#*                       Machine Learning API Framework                      *
#*																			 *
#*****************************************************************************
#
#	File Name:	pyq-stock-market-prediction.q
#
#	Facility:	Machine Learning API Framework
#
#	Purpose:	This module will aply linear regression to a dataset
#
#	Author:		Joel Oliveira, First Derivatives
#
#	Revision History
#
#	Date		Author				Description
#	-------		------------------	-------------------------------
#	15Aug17		Joel Oliveira		Original version

from pyq import q
import math
import pandas as pd
import time
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn import preprocessing, cross_validation
import datetime
import os

# Make sure python and Kdb are running on the same process
print "Python process: ", os.getpid()
print "Kdb process: ", q('.z.i,.z.f')

# Load data from the file
q('trade:("DFFFFFFFFFFFF"; enlist ",")0:`:aapl.csv')

#q.trade.show()

# Create a new column HL_PCT
q('trade:update Hl_Pct:((Adj_High - Adj_Low) % Adj_Close) * 100.0 from trade')

# Create a new column PCT_CHANGE
q('trade:update Pct_Change:((Adj_Close - Adj_Open) % Adj_Open) * 100.0 from trade')

# Remove non-used columns
q('trade: select Date, Adj_Close, Hl_Pct, Pct_Change, Adj_Volume from trade');

start = time.time()

# Create a new data frame using KDB table data.
dataFrame = pd.DataFrame(dict(q.trade.flip))

end = time.time()

print "Elapsed time in secs converting to data frame: ", (end - start)

# Get the last date for prediction propose.
last_date = dataFrame.iloc[-1].Date

# Create a new datset with the fields that we need for prediction.
dataFrame = dataFrame[['Adj_Close', 'Hl_Pct', 'Pct_Change', 'Adj_Volume']]

# Fill every Null row/field with -99999
dataFrame.fillna(value=-99999, inplace=True)

# Forecast prediction total: in days.
forecast_out = int(math.ceil(0.01 * len(dataFrame)))
print("Forecast: ", forecast_out)

# Create a new label to get the historical data for training.
dataFrame["label"] = dataFrame["Adj_Close"].shift(-forecast_out)

# Create a mew array with the data - label column
X = np.array(dataFrame.drop(["label"], 1))

# Standardize a dataset along any axis
X = preprocessing.scale(X)

# Get the forecast rows
X_lately = X[-forecast_out:]

# Remove the forecast rows from X
X = X[:-forecast_out]

# Return object with labels on given axis omitted where 
# alternately any or all of the data are missing
dataFrame.dropna(inplace=True)

# Get the lable for training
y = np.array(dataFrame["label"])

# Split arrays or matrices into random train and test subsets
X_train, X_test, y_train, y_test = cross_validation.train_test_split(X, y, test_size=0.2)

# Create the linear regression instance
clf = LinearRegression(n_jobs=-1)

# Fit the data
clf.fit(X_train, y_train)

# Get the accuracy based on the fit data
accuracy = clf.score(X_test, y_test)
print ("Accuracy: ", accuracy)

# Predict the value for forecast dates
forecast_set = clf.predict(X_lately)

# Clen the forecast column up
dataFrame["forecast"] = np.nan

# Get the last date saved and convert into a unix long format
last_unix = time.mktime(last_date.timetuple())
one_day = 86400
next_unix = last_unix + one_day

# Go over the forecast dataset and fill it.
for i in forecast_set:
    next_date = datetime.datetime.fromtimestamp(next_unix)
    next_unix += 86400
    dataFrame.loc[next_date] = [np.nan for _ in range(len(dataFrame.columns)-1)]+[i]

# Print the forecast out
print dataFrame["forecast"][-forecast_out:]
