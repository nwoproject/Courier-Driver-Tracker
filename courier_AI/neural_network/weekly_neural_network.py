import numpy as np
import pandas as pd
import tensorflow as tf
import urllib.request as request
import matplotlib.pyplot as plt
from tensorflow import keras
from tensorflow.keras.callbacks import ModelCheckpoint
import data.db_management as db


class NeuralNetwork:
    def __init__(self):
        self.labels = ['day1', 'day2', 'day3', 'day4', 'day5', 'expected']
        self.db_manager = db.DBManagement()

    def initialise(self):
        if self.importNN() is None:
            self.model = keras.Sequential([
                keras.layers.Flatten(input_shape=(5, 7)),  # input layer (1)
                keras.layers.Dense(128, activation='relu'),  # hidden layer (2)
                keras.layers.Dense(128, activation='relu'),
                keras.layers.Dense(4, activation='softmax')  # output layer (4)
            ])
            self.exportNN()

    def importNN(self):
        self.model = keras.models.load_model('models/weekly_model')

    def exportNN(self):
        self.model.save('models/weekly_model')

    def train(self):
        trainX = self.getTrainingInputData()
        trainY = self.getTrainingOutputData()
        self.checkpoint = ModelCheckpoint(
            self.config.model_path,
            monitor="val_acc",
            verbose=1,
            mode="max",
            save_best_only=True,
            save_weights_only=False,
            period=1
        )
        self.model.compile(optimizer='adam',
                      loss='sparse_categorical_crossentropy',
                      metrics=['accuracy'])
        self.model.fit(trainX,
                       trainY,
                       batchsize=100,
                       epochs=10,
                       shuffle=True,
                       validation_split = 0.1,
                       callbacks = [self.checkpoint]
        )
        self.exportNN()

    def getTrainingInputData(self):
        data = self.db_manager.getWeeklyInputs()
        for each in data:
            del each[-1]
        return data

    def getTrainingOutputData(self):
        data = self.db_manager.getWeeklyInputs()
        for each in range(0, len(data)):
            data[each] = data[each].pop()
        return data

    def getInputData(self):
        return


nn = NeuralNetwork()
print(nn.getTrainingInputData())
print("\n\n\n")
print(nn.getTrainingOutputData())

#test_loss, test_acc = model.evaluate(test, verbose=1)

#print('Test accuracy:', test_acc)
#predictions = model.predict(test)

#predictions[0]

