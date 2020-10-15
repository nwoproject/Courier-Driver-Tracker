import data.db_management as db
import neural_network.monthly_neural_network as mnn
import neural_network.weekly_neural_network as wnn


def main():
    array = db.DBManagement().getDriverInputs()
    # gets driver abnormalities from Neural Network database excluding the driver ID
    temp = []
    for each in range(0, len(array) - 1):
        temp2 = []
        for each2 in range(1, len(array[each]) - 1):
            temp2.append(array[each][each2])
        temp.append(temp2)

    # data is for input to neural network and array[0] for the driver ID
    data = temp
    for each in range(0, len(data) - 1):
        driverId = array[0]
        # insert each into Neural network predict
        # get output

    #   0 - long_stop
    #   1 - off_route
    #   2 - sudden_stop
    #   3 - company_car
    #   4 - speeding
    #   5 - neverStartedRoute
    #   6 - skippedDelivery

        array = db.DBManagement().insertWeeklyReport(# driverID, report, days, abnormalities, pattern)




if __name__ == "__main__":
    main()
