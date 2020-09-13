import psycopg2
import numpy as np
from copy import copy, deepcopy

class DBManagement:
    def __init__(self):
        self.host = "ec2-46-137-79-235.eu-west-1.compute.amazonaws.com"
        self.db_name = "ddvhk09prbb319"
        self.user = "sgeuntubjgaaek"
        self.password = "e914fb8aecf8c7311077b98de52252fc56d549705874e0e6ebf3e12dda278e02"
        self.port = "5432"
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


#test = DBManagement()
#day1 = [0, 0, 0, 0, 0, 0, 0]
#day3 = [0, 0, 0, 0, 0, 0, 0]
#day4 = [0, 0, 0, 0, 0, 0, 0]
#day5 = [0, 0, 0, 0, 0, 0, 0]
#expected = 0

#week = test.getMonthlyInputs()
#print(week)
