import numpy as np
import pandas as pd
import tensorflow as tf
import urllib.request as request
import matplotlib.pyplot as plt
from tensorflow import keras


class NeuralNetwork:

    #TRAIN = insert training data
    #TEST = insert test data

    names = ['day1', 'day2', 'day3', 'day4', 'day5', 'expected']
    #train = pd.read_data(TRAIN, names=names)
    #test = pd.read_data(TEST, names=names)

    model = keras.Sequential([
        keras.layers.Flatten(input_shape=(5, 7)),  # input layer (1)
        keras.layers.Dense(128, activation='relu'),  # hidden layer (2)
        keras.layers.Dense(128, activation='relu'),
        keras.layers.Dense(4, activation='softmax') # output layer (4)
    ])

    model.compile(optimizer='adam',
                  loss='sparse_categorical_crossentropy',
                  metrics=['accuracy'])

    #model.fit(train, epochs=10)

    #test_loss, test_acc = model.evaluate(test, verbose=1)

    #print('Test accuracy:', test_acc)
    #predictions = model.predict(test)


    #predictions[0]