import pandas as pd
import numpy as np
from time import time
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras.optimizers import Adam


train = pd.read_csv("engineered-train.csv")
test_ = pd.read_csv("engineered-test.csv")


X = train.ix[:, 2:-1].as_matrix()
y = train.ix[:, 1].as_matrix()

test = test_.ix[:, 2:-1].as_matrix()

model = Sequential()
model.add(Dense(8, input_dim=6, init='uniform', activation='relu'))
model.add(Dense(6, input_dim=8, init='uniform', activation='relu'))
model.add(Dense(1, init='uniform', activation='sigmoid'))

model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

model.fit(X, y, nb_epoch=600, batch_size=64, verbose=2)

predictions = model.predict_classes(test, batch_size=64)

submission = pd.DataFrame(predictions, columns=["Survived"])

submission["PassengerId"] = test_["PassengerId"]

submission = submission[["PassengerId", "Survived"]]

print(submission.head())

submission.to_csv("submission-{}.csv".format(time()), index=False)
