import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics import confusion_matrix, accuracy_score

data = pd.read_csv("C:\\Users\\fkhas\\Documents\\Projects\\Twitter\\SA\\analisissentimen\\Datasets\\Sentiment Idul Fitri.csv")

data.head(10)

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
x, x_test, y, y_test = train_test_split(x,y, stratify=y, test_size=0.10, random_state=42)

# Vectorize text reviews to numbers
vec = CountVectorizer()
x = vec.fit_transform(x).toarray()
x_test = vec.transform(x_test).toarray()

from sklearn.naive_bayes import BernoulliNB

model = BernoulliNB()
model.fit(x, y)

# score test data test
model.score(x_test, y_test)

# score for data training
model.score(x,y)

from jcopml.plot import plot_confusion_matrix
plot_confusion_matrix(x,y,x_test,y_test,model)

model.predict(vec.transform(['kalian brengsek']))

from jcopml.plot import plot_classification_report
plot_classification_report(x,y,x_test,y_test,model, report = True)
