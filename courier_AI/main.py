import data.db_management as db
import neural_network.monthly_neural_network as mnn
import neural_network.weekly_neural_network as wnn


def main():
    #wnn.NeuralNetwork.importNN()

    array = db.DBManagement().getDriverInputs()

    for each in array:
        print(each)

    # for each in range(0, len(array)):
        # for each2 in range(1, len(array[each]) - 1):
            # weeklyModel = wnn.nn.model(each)

    for each3 in range(0, len(array)):
        print(array[each3][])

        arr = []
        for each4 in range(1, len(array[each3]) - 1):
            arr2 = []
            arr2.append(array[each3][each4])
        arr.append(arr2)

    for each2 in arr:
        print(each2)

if __name__ == "__main__":
    main()
