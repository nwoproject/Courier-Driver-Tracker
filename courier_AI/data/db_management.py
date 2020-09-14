import dotenv
import psycopg2
import os
from copy import copy
import requests
import datetime

dotenv.load_dotenv()


class DBManagement:
    def __init__(self):
        self.host = os.getenv("DB_HOST")
        self.db_name = os.getenv("DB_NAME")
        self.user = os.getenv("DB_USER")
        self.password = os.getenv("DB_PASSWORD")
        self.port = "5432"
        self.conn = psycopg2.connect(database=self.db_name, user=self.user,
                                     password=self.password, host=self.host, port=self.port)
        self.connection()
        self.bearer = os.getenv("BEARER_TOKEN")

    def connection(self):
        try:
            check = self.conn
            print("Database connected successfully")
        except:
            print("Database not connected")

#   -------------NB-----------------
#   array structure for data to be sent:
#   day(n)[long_stop, off_route, sudden_stop, company_car, speeding, neverStartedRoute, skippedDelivery ]

#   0 - long_stop
#   1 - off_route
#   2 - sudden_stop
#   3 - company_car
#   4 - speeding
#   5 - neverStartedRoute
#   6 - skippedDelivery

#   Database inserters
    def insertWeeklyInputs(self, day1, day2, day3, day4, day5, expected):
        cursor = self.conn.cursor()
        sql = "INSERT INTO weekly_training (day1, day2, day3, day4, day5, expected) VALUES (%s, %s, %s, %s, %s, %s)"
        val = (day1, day2, day3, day4, day5, expected)
        cursor.execute(sql, val)
        self.conn.commit()
        print(cursor.rowcount, "weekly input inserted.")

    def insertMonthlyInputs(self, week1, week2, week3, week4, expected):
        cursor = self.conn.cursor()
        sql = "INSERT INTO monthly_training (week1, week2, week3, week4, expected) VALUES (%s, %s, %s, %s, %s)"
        val = (week1, week2, week3, week4, expected)
        cursor.execute(sql, val)
        self.conn.commit()
        print(cursor.rowcount, "monthly input inserted.")

#   Database GETTERS
    def getWeeklyInputs(self):

        data = []
        cursor = self.conn.cursor()
        sql = "SELECT day1, day2, day3, day4, day5, expected from weekly_training"
        cursor.execute(sql)
        self.conn.commit()

        records = cursor.fetchall()
        for row in records:
            data = copy(row)

        return data



    def getMonthlyInputs(self):

        data = []
        cursor = self.conn.cursor()
        sql = "SELECT week1, week2, week3, week4, expected from monthly_training"
        cursor.execute(sql)
        self.conn.commit()

        records = cursor.fetchall()
        for row in records:
            data = copy(row)

        return data

    def getDriverAbnormalities(self):

        r = requests.get(url="https://drivertracker-api.herokuapp.com/api/reports/drivers")
        data = r
        print(data)
        currTime = datetime.datetime.now()
        week = datetime.timedelta(days=7)
        result = currTime - week

        abnormalities = [[0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0]]


        for each in data["drivers"]:
            r2 = requests.get(url="https://drivertracker-api.herokuapp.com/api/abnormalities/:" + str(each["id"]))
            data2 = r2

            for each2 in data2["abnormalities"]["code_100"]["driver_abnormalities"]:
                if datetime.fromtimestamp(each2["timestamp"]) < result:
                    break
                else:
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 0:
                        abnormalities[0][0] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 1:
                        abnormalities[0][1] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 2:
                        abnormalities[0][2] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 3:
                        abnormalities[0][3] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 4:
                        abnormalities[0][4] += 1

            for each2 in data2["abnormalities"]["code_101"]["driver_abnormalities"]:
                if datetime.fromtimestamp(each2["timestamp"]) < result:
                    break
                else:
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 0:
                        abnormalities[1][0] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 1:
                        abnormalities[1][1] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 2:
                        abnormalities[1][2] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 3:
                        abnormalities[1][3] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 4:
                        abnormalities[1][4] += 1

            for each2 in data2["abnormalities"]["code_102"]["driver_abnormalities"]:
                if datetime.fromtimestamp(each2["timestamp"]) < result:
                    break
                else:
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 0:
                        abnormalities[2][0] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 1:
                        abnormalities[2][1] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 2:
                        abnormalities[2][2] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 3:
                        abnormalities[2][3] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 4:
                        abnormalities[2][4] += 1

            for each2 in data2["abnormalities"]["code_103"]["driver_abnormalities"]:
                if datetime.fromtimestamp(each2["timestamp"]) < result:
                    break
                else:
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 0:
                        abnormalities[3][0] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 1:
                        abnormalities[3][1] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 2:
                        abnormalities[3][2] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 3:
                        abnormalities[3][3] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 4:
                        abnormalities[3][4] += 1

            for each2 in data2["abnormalities"]["code_104"]["driver_abnormalities"]:
                if datetime.fromtimestamp(each2["timestamp"]) < result:
                    break
                else:
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 0:
                        abnormalities[4][0] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 1:
                        abnormalities[4][1] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 2:
                        abnormalities[4][2] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 3:
                        abnormalities[4][3] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 4:
                        abnormalities[4][4] += 1

            for each2 in data2["abnormalities"]["code_105"]["driver_abnormalities"]:
                if datetime.fromtimestamp(each2["timestamp"]) < result:
                    break
                else:
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 0:
                        abnormalities[5][0] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 1:
                        abnormalities[5][1] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 2:
                        abnormalities[5][2] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 3:
                        abnormalities[5][3] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 4:
                        abnormalities[5][4] += 1

            for each2 in data2["abnormalities"]["code_106"]["driver_abnormalities"]:
                if datetime.fromtimestamp(each2["timestamp"]) < result:
                    break
                else:
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 0:
                        abnormalities[6][0] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 1:
                        abnormalities[6][1] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 2:
                        abnormalities[6][2] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 3:
                        abnormalities[6][3] += 1
                    if datetime.fromtimestamp(each2["timestamp"]).weekday() == 4:
                        abnormalities[6][4] += 1
        return abnormalities

db = DBManagement()
db.getDriverAbnormalities()



