import data.db_management as db
import neural_network.monthly_neural_network as mnn
import neural_network.weekly_neural_network as wnn


def main():

    weekNN = wnn.NeuralNetwork()
    weekNN.model_path = "neural_network/models/WeeklyModel/"
    weekNN.importNN()

    array = db.DBManagement().getDriverInputs()
    # gets driver abnormalities from Neural Network database excluding the driver ID
    temp = []
    tempID = []
    for each in range(0, len(array)):
        tempID.append(array[each][0])
        temp2 = []
        for each2 in range(1, len(array[each])):
            temp2.append(array[each][each2])

            abnormal = [0, 0, 0, 0, 0, 0, 0]
            for each3 in range(0, len(array[each][each2])):
                if array[each][each2][each3] > 0:
                    abnormal[each3] += 1
        temp.append(temp2)

    # data is for input to neural network and array[0] for the driver ID
    data = temp

    for each in range(0, len(data)):
        abnormalities = []
        driverId = tempID[each]
        arr2 = weekNN.model.predict([data[each]])

        max = 0
        maxVal = 0
        for each2 in range(0, len(arr2[0])):
            if arr2[0][each2] > maxVal:
                max = each2
                maxVal = arr2[0][each2]

        if max == 0:
            pattern = "None"
            abnormalities = [-1]

        if max == 1:
            pattern = "Daily"
            for i in range(0, len(abnormal)):
                if abnormal[i] == 5:
                    abnormalities.append(i)


        if max == 2:
            pattern = "Recurring"
            for i in range(0, len(abnormal)):
                if abnormal[i] > 1 :
                    abnormalities.append(i)

        if max == 3:
            pattern = "Connected recurring"
            for i in range(0, len(abnormal)):
                for k in range(i+1, len(abnormal)):
                    if abnormal[i] == abnormal[k] and abnormal[i] > 0:
                        try:
                            b = abnormalities.index(i)
                        except ValueError:
                            abnormalities.append(i)

        days = []

        for i in range(0, len(data[each])):
            for j in range(0, len(abnormalities)):
                if abnormalities[j] >= 0 and data[each][i][abnormalities[j]] > 0:
                    days.append(i)
                else:
                    days.append(-1)
                    break

        for j in range(0, len(abnormalities)):
            abnormalities[j] += 100

        report = [0, 0, 0, 0]
        report[max] = 1

        array = db.DBManagement().insertWeeklyReport(driverId, report, days, abnormalities, pattern)
        # insert each into Neural network predict
        # get output

    #   0 - long_stop
    #   1 - off_route
    #   2 - sudden_stop
    #   3 - company_car
    #   4 - speeding
    #   5 - neverStartedRoute
    #   6 - skippedDelivery


if __name__ == "__main__":
    main()
