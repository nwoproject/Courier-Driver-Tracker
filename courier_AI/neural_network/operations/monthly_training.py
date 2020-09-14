import random
import data.db_management


class MonthlyTraining:
    def __init__(self, db_manager):
        self.manager = db_manager

    def createMonthlyTrainingElement(self, training_type):
        data = [[0, 0, 0, 0],
                [0, 0, 0, 0],
                [0, 0, 0, 0],
                [0, 0, 0, 0],
                0]

        if training_type == "none":
            data[4] = 0
            case = random.randrange(0, 2)

            if case == 0:
                for each in data:
                    limit = 100
                    randomValue = random.randrange(75, limit)
                    data[each][0] = randomValue/100
                    limit -= randomValue
                    randomValue = random.randrange(0, limit)
                    data[each][1] = randomValue / 100
                    limit -= randomValue
                    randomValue = random.randrange(0, limit)
                    data[each][2] = randomValue / 100
                    limit -= randomValue
                    data[each][3] = limit

            else:
                for each in data:
                    limit = 100
                    randomValue = random.randrange(0, limit)
                    data[each][0] = randomValue/100
                    limit -= randomValue
                    randomValue = random.randrange(0, limit)
                    data[each][1] = randomValue / 100
                    limit -= randomValue
                    randomValue = random.randrange(0, limit)
                    data[each][2] = randomValue / 100
                    limit -= randomValue
                    data[each][3] = limit

        elif training_type == "daily":
            data[4] = 1
            numberOfAbnormalities = random.randrange(5, 35)
            variant = random.randrange(0, 10)
            abnormality = random.randrange(0, 6)
            while numberOfAbnormalities > 0:
                for i in range(0, 6):
                    data[i][abnormality] += 1
                    numberOfAbnormalities -= 1

            while variant > 0:
                day = random.randrange(0, 4)
                abnormality = random.randrange(0, 6)
                data[day][abnormality] += 1
                variant -= 1

        elif training_type == "racurring":
            data[4] = 2
            numDayRepeat = random.randrange(2, 4)
            numberOfAbnormalities = random.randrange(15, 35)
            variant = random.randrange(0, 10)

            days = []
            while numDayRepeat > 0:
                day = random.randrange(0, 4)
                if days.__contains__(day):
                    continue
                days.append(day)
                numDayRepeat -= 1

            abnormality = random.randrange(0, 6)

            while numberOfAbnormalities > 0:
                day = random.randrange(0, len(days))
                data[day][abnormality] += 1
                numberOfAbnormalities -= 1

            while variant > 0:
                day = random.randrange(0, 4)
                abnormality = random.randrange(0, 6)
                data[day][abnormality] += 1
                variant -= 1

        elif training_type == "connected-recurring":
            data[4] = 3
            numDayRepeat = random.randrange(2, 4)
            numAbnormalityRepeat = random.randrange(2, 3)
            numberOfAbnormalities = random.randrange(numAbnormalityRepeat * numDayRepeat, 35)
            variant = random.randrange(0, 10)

            days = []
            while numDayRepeat > 0:
                day = random.randrange(0, 4)
                if days.__contains__(day):
                    continue
                days.append(day)
                numDayRepeat -= 1

            abnormality1 = random.randrange(0, 6)
            abnormality2 = random.randrange(0, 6)
            abnormality3 = random.randrange(0, 6)

            while abnormality1 == abnormality2 or abnormality1 == abnormality3 or abnormality2 == abnormality3:
                abnormality1 = random.randrange(0, 6)
                abnormality2 = random.randrange(0, 6)
                abnormality3 = random.randrange(0, 6)

            while numberOfAbnormalities > 0:
                day = random.randrange(0, len(days))
                data[day][abnormality1] += 1
                data[day][abnormality2] += 1

                if numAbnormalityRepeat > 2:
                    data[day][abnormality3] += 1
                    numberOfAbnormalities -= 1

                numberOfAbnormalities -= 2

            while variant > 0:
                day = random.randrange(0, 4)
                abnormality = random.randrange(0, 6)
                data[day][abnormality] += 1
                variant -= 1

        else:
            return

        return data

    def createMonthlyTrainingElement(self, training_size):
        calculatedData = []
        for each in range(0, 4):
            for element in range(0, round(training_size/4)):
                calculatedData.append(self.createWeeklyTrainingElement(each))

        for each in calculatedData:
            print("Doin it!")


training = MonthlyTraining("hello")
