import numpy as np
import pandas as pd
import tensorflow as tf
import urllib.request as request
import matplotlib.pyplot as plt
from tensorflow import keras
from tensorflow.keras.callbacks import ModelCheckpoint
import data.db_management as db
import pydot


class NeuralNetwork:
    def __init__(self):
        self.model_path = 'models/MonthlyModel'
        self.checkpoint = ModelCheckpoint(
            self.model_path,
            monitor="val_acc",
            verbose=1,
            mode="max",
            save_best_only=True,
            save_weights_only=False,
            period=1
        )
        self.db_manager = db.DBManagement()
        self.initialise()

    def initialise(self):
        self.model = keras.Sequential([
            keras.layers.Dense(units=20, input_shape=(4, 5)),  # input layer (1)tr
            keras.layers.Flatten(),
            keras.layers.Dense(128, activation='relu'),  # hidden layer (2)
            keras.layers.Dense(128, activation='relu'),
            keras.layers.Dense(4, activation='softmax')  # output layer (4)

        ])

        self.exportNN()

    def importNN(self):
        self.model = keras.models.load_model(self.model_path)

    def exportNN(self):
        self.model.save(self.model_path)

    def train(self):

        trainX = np.asarray(self.getMonthlyInputData())
        trainY = np.asarray(self.getMonthlyOutputData())
        print(len(trainX))
        print(len(trainY))
        print("X" + str(trainX.shape))
        print("Y" + str(trainY.shape))

        self.model.compile(optimizer='adam',
                           loss='sparse_categorical_crossentropy',
                           metrics=['accuracy'])
        graph = self.model.fit(trainX,
                       trainY,
                       batch_size=100,
                       epochs=3,
                       shuffle=True,
                       validation_split=0.1,
                       callbacks=[self.checkpoint]
                       )

        self.exportNN()

        plt.plot(graph.history['accuracy'])
        plt.plot(graph.history['val_accuracy'])
        plt.title('model accuracy')
        plt.ylabel('accuracy')
        plt.xlabel('epoch')
        plt.legend(['train', 'val'], loc='upper left')
        plt.show()

        plt.plot(graph.history['loss'])
        plt.plot(graph.history['val_loss'])
        plt.title('model loss')
        plt.ylabel('loss')
        plt.xlabel('epoch')
        plt.legend(['train', 'val'], loc='upper left')
        plt.show()

    def getMonthlyInputData(self):
        data = self.db_manager.getMonthlyInputs()
        for each in range(0, len(data)):
            temp_arr = []
            for each2 in range(0, len(data[each]) - 1):
                temp = []
                for val in data[each][each2]:
                    temp.append(val)
                temp_arr.append(temp)
            data[each] = temp_arr
        return data

    def getMonthlyOutputData(self):
        data = self.db_manager.getMonthlyInputs()
        for each in range(0, len(data)):
            temp_arr = []

            for each2 in range(0, len(data[each])):
                expected = data[each][4]
                temp_arr.append(expected)
            data[each] = temp_arr

        output = []
        for this in range(0, len(data)):
            if data[this][0] == 0:
                tem = 0
                output.append(tem)
            if data[this][0] == 1:
                tem = 1
                output.append(tem)
            if data[this][0] == 2:
                tem = 2
                output.append(tem)
            if data[this][0] == 3:
                tem = 3
                output.append(tem)
            if data[this][0] == 4:
                tem = 3
                output.append(tem)

        return output


