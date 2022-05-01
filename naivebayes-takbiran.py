import pandas as pd
from sklearn.model_selection import train_test_split
import joblib
from sklearn.feature_extraction.text import CountVectorizer

data = pd.read_csv("C:\\Users\\fkhas\\Documents\\Projects\\Twitter\\SA\\tugasakhirfix\\Datasets\\Sentiment Takbiran.csv")

data.head()

import re
from nltk.corpus import stopwords

def preprocess_data(data):
    # Remove package name as it's not relevant
    data = data.drop('score', axis=1)
    
    # Convert text to lowercase
    data['text'] = data['text'].str.strip().str.lower()
    return data
  
data = preprocess_data(data)

# Split into training and testing data
x = data['text']
y = data['class']
x, x_test, y, y_test = train_test_split(x,y, stratify=y, test_size=0.25, random_state=42)  

# Vectorize text reviews to numbers
vec = CountVectorizer(stop_words='english')
x = vec.fit_transform(x).toarray()
x_test = vec.transform(x_test).toarray()

from sklearn.naive_bayes import MultinomialNB

model = MultinomialNB()
model.fit(x, y)

model.score(x_test, y_test)

model.predict(vec.transform(['saya benci kamu!']))
