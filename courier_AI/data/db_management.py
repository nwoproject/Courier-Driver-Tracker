import dotenv
import psycopg2
import os
from copy import copy

dotenv.load_dotenv()


class DBManagement:
    def __init__(self):
        self.host = os.getenv("DB_HOST")
        self.db_name = os.getenv("DB_NAME")
        self.user = os.getenv("DB_USER")
        self.password = os.getenv("DB_PASSWORD")
        self.port = os.getenv("DB_PORT")
        self.conn = psycopg2.connect(database=self.db_name, user=self.user,
                                     password=self.password, host=self.host, port=self.port)
        self.connection()

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

        return records


    def getMonthlyInputs(self):

        data = []
        cursor = self.conn.cursor()
        sql = "SELECT week1, week2, week3, week4, expected from monthly_training"
        cursor.execute(sql)
        self.conn.commit()

        records = cursor.fetchall()

        return records


#   Row Deletions

    #   deletes row based on expected value
    def deleteWeekRow(self, expected):

        cursor = self.conn.cursor()
        sql = "DELETE from weekly_training where expected = " + str(expected)
        cursor.execute(sql)
        self.conn.commit()
        print(cursor.rowcount, "weekly row(s) deleted.")

    def deleteMonthRow(self, expected):

        cursor = self.conn.cursor()
        sql = "DELETE from monthly_training where expected = " + str(expected)
        cursor.execute(sql)
        self.conn.commit()
        print(cursor.rowcount, "monthly row(s) deleted.")
