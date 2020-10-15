import random
import data.db_management as db
import data.db_management
import datetime
import tensorflow as tf
import json


class WeeklyTraining:
    def __init__(self, db_manager):
        self.db_manager = db_manager

    def createWeeklyTrainingElement(self, training_type):
        data = [[0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0],
                0]

        if training_type == 0:
            data[5] = 0
            numberOfAbnormalities = random.randrange(0, 56)
            while numberOfAbnormalities > 0:
                day = random.randrange(0, 5)
                abnormality = random.randrange(0, 7)
                if abnormality == 6 and data[day][abnormality] >= 3:
                    continue
                data[day][abnormality] += 1
                numberOfAbnormalities -= 1

        elif training_type == 1:
            data[5] = 1
            numberOfAbnormalities = random.randrange(5, 36)
            variant = random.randrange(0, 11)
            abnormality = random.randrange(0, 7)
            while numberOfAbnormalities > 0:
                for i in range(0, 5):
                    data[i][abnormality] += 1
                    numberOfAbnormalities -= 1

            while variant > 0:
                day = random.randrange(0, 5)
                abnormality = random.randrange(0, 7)
                data[day][abnormality] += 1
                variant -= 1

        elif training_type == 2:
            data[5] = 2
            numDayRepeat = random.randrange(2, 5)
            numberOfAbnormalities = random.randrange(15, 36)
            variant = random.randrange(0, 11)

            days = []
            while numDayRepeat > 0:
                day = random.randrange(0, 5)
                if days.__contains__(day):
                    continue
                days.append(day)
                numDayRepeat -= 1

            abnormality = random.randrange(0, 7)

            while numberOfAbnormalities > 0:
                day = random.randrange(0, len(days))
                data[day][abnormality] += 1
                numberOfAbnormalities -= 1

            while variant > 0:
                day = random.randrange(0, 5)
                abnormality = random.randrange(0, 7)
                data[day][abnormality] += 1
                variant -= 1

        elif training_type == 3:
            data[5] = 3
            numDayRepeat = random.randrange(2, 5)
            numAbnormalityRepeat = random.randrange(2, 5)
            numberOfAbnormalities = random.randrange(numAbnormalityRepeat * numDayRepeat, 36)
            variant = random.randrange(0, 11)

            days = []
            while numDayRepeat > 0:
                day = random.randrange(0, 5)
                if days.__contains__(day):
                    continue
                days.append(day)
                numDayRepeat -= 1

            abnormality1 = random.randrange(0, 7)
            abnormality2 = random.randrange(0, 7)
            abnormality3 = random.randrange(0, 7)

            while abnormality1 == abnormality2 or abnormality1 == abnormality3 or abnormality2 == abnormality3:
                abnormality1 = random.randrange(0, 7)
                abnormality2 = random.randrange(0, 7)
                abnormality3 = random.randrange(0, 7)

            while numberOfAbnormalities > 0:
                day = random.randrange(0, len(days))
                data[day][abnormality1] += 1
                data[day][abnormality2] += 1

                if numAbnormalityRepeat > 2:
                    data[day][abnormality3] += 1
                    numberOfAbnormalities -= 1

                numberOfAbnormalities -= 2

            while variant > 0:
                day = random.randrange(0, 5)
                abnormality = random.randrange(0, 7)
                data[day][abnormality] += 1
                variant -= 1

        else:
            return

        return data

    def createWeeklyTrainingSet(self, training_size):
        calculatedData = []
        for each in range(0, 4):
            self.db_manager.deleteWeekRow(each)
            for element in range(0, round(training_size / 4)):
                data = self.createWeeklyTrainingElement(each)
                print(data)
                calculatedData.append(data)

        for each in calculatedData:
            self.db_manager.insertWeeklyInputs(each[0],
                                               each[1],
                                               each[2],
                                               each[3],
                                               each[4],
                                               each[5])


training = WeeklyTraining(db.DBManagement())
training.generateWeeklyReport()

#training.createWeeklyTrainingSet(4000)
#print("done")

