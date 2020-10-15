import dotenv
import psycopg2
import os

from requests import Request, Session
from datetime import datetime, timedelta


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

    def insertWeeklyReport(self, driverID, report, days, abnormalities, pattern):

        data = {
            "patternsDetected": pattern,
            "abnormalities": abnormalities,
            "days": days
        }

        r = Session()
        headers = {
            'Accept': 'application/json',
            'Authorization': 'Bearer ' + str(self.bearer)
        }
        req = Request('POST', "https://drivertracker-api.herokuapp.com/api/patterns/weekly/" + str(driverID),
                      headers=headers, data=data)
        prepped = r.prepare_request(req)
        resp = r.send(prepped)

        cursor = self.conn.cursor()
        sql = "INSERT INTO weekly_reports (driver_id, report, days, abnormalities, pattern) " \
              "VALUES (%s, %s, %s, %s, %s)"

        val = (driverID, report, days, abnormalities, pattern)
        cursor.execute(sql, val)
        self.conn.commit()
        print(cursor.rowcount, "weekly report inserted.")

    def insertMonthlyReport(self, driverID, report, weeks, abnormalities, pattern):

        data = {
            "patternsDetected": pattern,
            "abnormalities": abnormalities,
            "weeks": weeks
        }

        r = Session()
        headers = {
            'Accept': 'application/json',
            'Authorization': 'Bearer ' + str(self.bearer)
        }
        req = Request('POST', "https://drivertracker-api.herokuapp.com/api/patterns/monthly/" + str(driverID),
                      headers=headers, data=data)
        prepped = r.prepare_request(req)
        resp = r.send(prepped)

        cursor = self.conn.cursor()
        sql = "INSERT INTO monthly_reports (driver_id, report, weeks, abnormalities, pattern) " \
              "VALUES (%s, %s, %s, %s, %s)"

        val = (driverID, report, weeks, abnormalities, pattern)
        cursor.execute(sql, val)
        self.conn.commit()
        print(cursor.rowcount, "monthly report inserted.")

    def insertDriverAbnormalities(self, driverID, day1, day2, day3, day4, day5):
        cursor = self.conn.cursor()
        sql = "INSERT INTO driver_abnormalities (driver_id, day1, day2, day3, day4, day5) " \
              "VALUES (%s, %s, %s, %s, %s, %s)"
        val = (driverID, day1, day2, day3, day4, day5)
        cursor.execute(sql, val)
        self.conn.commit()
        print(cursor.rowcount, "Abnormalities for driver with ID: " + str(driverID) + " have been inserted")

    #   Database GETTERS
    def getDriverInputs(self):
        cursor = self.conn.cursor()
        sql = "SELECT driver_id, day1, day2, day3, day4, day5 from driver_abnormalities"
        cursor.execute(sql)
        self.conn.commit()

        records = cursor.fetchall()

        return records

    def getWeeklyInputs(self):

        cursor = self.conn.cursor()
        sql = "SELECT day1, day2, day3, day4, day5, expected from weekly_training"
        cursor.execute(sql)
        self.conn.commit()

        records = cursor.fetchall()

        return records

    def getMonthlyInputs(self):

        cursor = self.conn.cursor()
        sql = "SELECT week1, week2, week3, week4, expected from monthly_training"
        cursor.execute(sql)
        self.conn.commit()

        records = cursor.fetchall()

        return records

    def getTrainingInputData(self):
        data = self.db_manager.getWeeklyInputs()
        for each in range(0, len(data)):
            temp_arr = []
            for each2 in range(0, len(data[each]) - 1):
                temp = []
                for val in data[each][each2]:
                    temp.append(val)
                temp_arr.append(temp)
            data[each] = temp_arr
        return data

    @property
#   Database deletes

    def deleteWeeklyTraining(self, expected):

        cursor = self.conn.cursor()
        sql = "DELETE from weekly_training where expected =" + str(expected)
        cursor.execute(sql)
        self.conn.commit()

    def deleteMonthlyTraining(self, expected):

        cursor = self.conn.cursor()
        sql = "DELETE from monthly_training where expected =" + str(expected)
        cursor.execute(sql)
        self.conn.commit()

    def deleteWeeklyReportRow(self, driverID):

        cursor = self.conn.cursor()
        sql = "DELETE from weekly_reports where driver_id =" + str(driverID)
        cursor.execute(sql)
        self.conn.commit()
        print("driver with ID: " + str(driverID) + " weekly reports have been removed")

    def deleteMonthlyReportRow(self, driverID):

        cursor = self.conn.cursor()
        sql = "DELETE from monthly_reports where driver_id =" + str(driverID)
        cursor.execute(sql)
        self.conn.commit()
        print("driver with ID: " + str(driverID) + " monthly reports have been removed")


    def getDriverAbnormalities(self):

        s = Session()
        headers = {
            'Accept': 'application/json',
            'Authorization': 'Bearer ' + str(self.bearer)
        }
        req = Request('GET', "https://drivertracker-api.herokuapp.com/api/reports/drivers", headers=headers)
        prepped = s.prepare_request(req)
        resp = s.send(prepped).json()

        data = resp
        currTime = datetime.now()
        week = timedelta(days=7)
        result = currTime - week

        for each in data["drivers"]:

            abnormalities = [[0, 0, 0, 0, 0, 0, 0],
                             [0, 0, 0, 0, 0, 0, 0],
                             [0, 0, 0, 0, 0, 0, 0],
                             [0, 0, 0, 0, 0, 0, 0],
                             [0, 0, 0, 0, 0, 0, 0]]

            req2 = Request('GET', "https://drivertracker-api.herokuapp.com/api/abnormalities/" + str(each['id']),
                              headers=headers)
            prepped = s.prepare_request(req2)
            resp2 = s.send(prepped)

            if resp2.status_code == 204:
                self.insertDriverAbnormalities(int(each['id']), abnormalities[0], abnormalities[1], abnormalities[2],
                                               abnormalities[3], abnormalities[4])
                continue

            resp2 = resp2.json()
            data2 = resp2

            for each2 in data2["abnormalities"]["code_100"]["driver_abnormalities"]:
                date_str = each2["timestamp"]
                date_str = date_str.split(".")
                date_str = date_str[0]
                date_dt = datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')
                if date_dt < result:
                    continue
                else:
                    if date_dt.weekday() == 0:
                        abnormalities[0][0] += 1
                    if date_dt.weekday() == 1:
                        abnormalities[1][0] += 1
                    if date_dt.weekday() == 2:
                        abnormalities[2][0] += 1
                    if date_dt.weekday() == 3:
                        abnormalities[3][0] += 1
                    if date_dt.weekday() == 4:
                        abnormalities[4][0] += 1


            for each2 in data2["abnormalities"]["code_101"]["driver_abnormalities"]:
                date_str = each2["timestamp"]
                date_str = date_str.split(".")
                date_str = date_str[0]
                date_dt = datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')
                if date_dt < result:
                    continue
                else:
                    if date_dt.weekday() == 0:
                        abnormalities[0][1] += 1
                    if date_dt.weekday() == 1:
                        abnormalities[1][1] += 1
                    if date_dt.weekday() == 2:
                        abnormalities[2][1] += 1
                    if date_dt.weekday() == 3:
                        abnormalities[3][1] += 1
                    if date_dt.weekday() == 4:
                        abnormalities[4][1] += 1

            for each2 in data2["abnormalities"]["code_102"]["driver_abnormalities"]:
                date_str = each2["timestamp"]
                date_str = date_str.split(".")
                date_str = date_str[0]
                date_dt = datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')
                if date_dt < result:
                    continue
                else:
                    if date_dt.weekday() == 0:
                        abnormalities[0][2] += 1
                    if date_dt.weekday() == 1:
                        abnormalities[1][2] += 1
                    if date_dt.weekday() == 2:
                        abnormalities[2][2] += 1
                    if date_dt.weekday() == 3:
                        abnormalities[3][2] += 1
                    if date_dt.weekday() == 4:
                        abnormalities[4][2] += 1

            for each2 in data2["abnormalities"]["code_103"]["driver_abnormalities"]:
                date_str = each2["timestamp"]
                date_str = date_str.split(".")
                date_str = date_str[0]
                date_dt = datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')
                if date_dt < result:
                    continue
                else:
                    if date_dt.weekday() == 0:
                        abnormalities[0][3] += 1
                    if date_dt.weekday() == 1:
                        abnormalities[1][3] += 1
                    if date_dt.weekday() == 2:
                        abnormalities[2][3] += 1
                    if date_dt.weekday() == 3:
                        abnormalities[3][3] += 1
                    if date_dt.weekday() == 4:
                        abnormalities[4][3] += 1

            for each2 in data2["abnormalities"]["code_104"]["driver_abnormalities"]:
                date_str = each2["timestamp"]
                date_str = date_str.split(".")
                date_str = date_str[0]
                date_dt = datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')
                if date_dt < result:
                    continue
                else:
                    if date_dt.weekday() == 0:
                        abnormalities[0][4] += 1
                    if date_dt.weekday() == 1:
                        abnormalities[1][4] += 1
                    if date_dt.weekday() == 2:
                        abnormalities[2][4] += 1
                    if date_dt.weekday() == 3:
                        abnormalities[3][4] += 1
                    if date_dt.weekday() == 4:
                        abnormalities[4][4] += 1

            for each2 in data2["abnormalities"]["code_105"]["driver_abnormalities"]:
                date_str = each2["timestamp"]
                date_str = date_str.split(".")
                date_str = date_str[0]
                date_dt = datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')
                if date_dt < result:
                    continue
                else:
                    if date_dt.weekday() == 0:
                        abnormalities[0][5] += 1
                    if date_dt.weekday() == 1:
                        abnormalities[1][5] += 1
                    if date_dt.weekday() == 2:
                        abnormalities[2][5] += 1
                    if date_dt.weekday() == 3:
                        abnormalities[3][5] += 1
                    if date_dt.weekday() == 4:
                        abnormalities[4][5] += 1

            for each2 in data2["abnormalities"]["code_106"]["driver_abnormalities"]:
                date_str = each2["timestamp"]
                date_str = date_str.split(".")
                date_str = date_str[0]
                date_dt = datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')
                if date_dt < result:
                    continue
                else:
                    if date_dt.weekday() == 0:
                        abnormalities[0][6] += 1
                    if date_dt.weekday() == 1:
                        abnormalities[1][6] += 1
                    if date_dt.weekday() == 2:
                        abnormalities[2][6] += 1
                    if date_dt.weekday() == 3:
                        abnormalities[3][6] += 1
                    if date_dt.weekday() == 4:
                        abnormalities[4][6] += 1
            self.insertDriverAbnormalities(int(each['id']), abnormalities[0], abnormalities[1], abnormalities[2],
                                           abnormalities[3], abnormalities[4])
        return abnormalities

db = DBManagement()
# db.insertMonthlyReport(20, [-1, 0.0, 0.1, 0.0, 0.0], [-1, 1], [-1, 102, 103, 106], "Recurring")
# db.insertWeeklyReport(20, [-1, 0, 0, 0, 1, 0], [2, 3], [-1, 102, 103], "Recurring")
