import random
import data.db_management as db


class MonthlyTraining:
    def __init__(self, db_manager):
        self.db_manager = db_manager

    def createMonthlyTrainingElement(self, training_type):
        data = [[0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                0]

        if training_type == 0:
            data[4] = 0

            for each in range(0, 4):
                limit = 100
                random_value = random.randrange(75, limit)
                data[each][0] = random_value / 100
                limit -= random_value
                random_value = random.randrange(0, limit)
                data[each][1] = random_value / 100
                limit -= random_value
                random_value = random.randrange(0, limit)
                data[each][2] = random_value / 100
                limit -= random_value
                data[each][3] = limit / 100

        elif training_type == 1:
            data[4] = 1
            for each in range(0, 4):
                limit = 100
                random_value = random.randrange(75, limit)
                data[each][1] = random_value
                limit -= random_value
                random_value = random.randrange(0, limit)
                data[each][0] = random_value / 100
                limit -= random_value
                random_value = random.randrange(0, limit)
                data[each][2] = random_value / 100
                limit -= random_value
                data[each][3] = limit / 100

        elif training_type == 2:
            data[4] = 2
            week = random.randrange(0, 4)
            abnormalities_chosen = [1, 2, 3, 4]
            chosen_abnormality = random.randrange(0, len(abnormalities_chosen))
            abnormality = chosen_abnormality
            limit = 100
            random_value = random.randrange(75, limit)
            while len(abnormalities_chosen) > 1:
                data[week][abnormalities_chosen[abnormality]] = random_value / 100
                abnormalities_chosen.remove(abnormalities_chosen[abnormality])
                random_value = random.randrange(0, limit)
                abnormality = random.randrange(0, len(abnormalities_chosen))
                limit -= random_value

            data[week][0] = random_value / 100

            for each in range(0, 4):
                if each == week:
                    continue
                abnormalities_chosen = []
                limit = 100
                random_value = random.randrange(75, limit)
                for ab in range(0, 5):
                    if ab == chosen_abnormality:
                        continue
                    abnormalities_chosen.append(ab)

                while len(abnormalities_chosen) > 1:
                    data[each][abnormalities_chosen[abnormality]] = random_value / 100
                    abnormalities_chosen.remove(abnormalities_chosen[abnormality])
                    random_value = random.randrange(0, limit)
                    abnormality = random.randrange(0, len(abnormalities_chosen))
                    limit -= random_value

                data[each][chosen_abnormality] = random_value / 100

        elif training_type == 3:
            data[4] = 3
            weeks = []
            num_weeks = random.randrange(2, 5)

            while len(weeks) < num_weeks:
                week = random.randrange(0, 4)
                if weeks.count(week) > 0:
                    continue
                weeks.append(week)

            for each in range(0, 4):
                if weeks.count(each) > 0:
                    limit = 100
                    random_value = random.randrange(75, limit)
                    data[each][2] = random_value / 100
                    limit -= random_value
                    random_value = random.randrange(0, limit)
                    data[each][0] = random_value / 100
                    limit -= random_value
                    random_value = random.randrange(0, limit)
                    data[each][1] = random_value / 100
                    limit -= random_value
                    data[each][3] = limit / 100
                else:
                    limit = 100
                    random_value = random.randrange(0, limit)
                    data[each][0] = random_value / 100
                    limit -= random_value
                    random_value = random.randrange(0, limit)
                    data[each][1] = random_value / 100
                    limit -= random_value
                    random_value = random.randrange(0, limit)
                    data[each][2] = random_value / 100
                    limit -= random_value
                    data[each][3] = limit / 100

        elif training_type == 4:
            data[4] = 4
            weeks = []
            num_weeks = random.randrange(2, 4)

            while len(weeks) < num_weeks:
                week = random.randrange(0, 4)
                if weeks.count(week) > 0:
                    continue
                weeks.append(week)

            for each in range(0, 4):
                if weeks.count(each) > 0:
                    limit = 100
                    random_value = random.randrange(75, limit)
                    data[each][3] = random_value / 100
                    limit -= random_value
                    random_value = random.randrange(0, limit)
                    data[each][0] = random_value / 100
                    limit -= random_value
                    random_value = random.randrange(0, limit)
                    data[each][1] = random_value / 100
                    limit -= random_value
                    data[each][2] = limit / 100
                else:
                    limit = 100
                    random_value = random.randrange(0, limit)
                    data[each][0] = random_value / 100
                    limit -= random_value
                    random_value = random.randrange(0, limit)
                    data[each][1] = random_value / 100
                    limit -= random_value
                    random_value = random.randrange(0, limit)
                    data[each][2] = random_value / 100
                    limit -= random_value
                    data[each][3] = limit / 100
        else:
            return

        return data

    def createMonthlyTrainingSet(self, training_size):
        calculatedData = []
        for each in range(0, 5):
            self.db_manager.deleteMonthRow(each)
            for element in range(0, round(training_size / 5)):
                calculatedData.append(self.createMonthlyTrainingElement(each))

        for each in calculatedData:
            self.db_manager.insertMonthlyInputs(each[0],
                                                each[1],
                                                each[2],
                                                each[3],
                                                each[4])


training = MonthlyTraining(db.DBManagement())
training.createMonthlyTrainingSet(4000)
print("noice")
