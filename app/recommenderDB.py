# -*- coding: utf-8 -*-
"""
Created on Sun Oct 30 20:56:06 2016
cic
@author: Andy
"""
'''
User Guide:

1. initialize once and then commit to save your database
2. next time, when you want to use it, just t = minidatabase('db_name.db')
3. generally speaking, you just need to write a command(sql), and run t.query_show()
   to show the first result. t.query_show

'''
import sqlite3
import os
import csv
import re
import pandas as pd
from datetime import datetime
import numpy as np
sqlite3.register_adapter(np.int64, lambda val: int(val))
sqlite3.register_adapter(np.float64, lambda val: float(val))
class EmptyError(Exception):
    pass
class minidatabase:
    def __init__(self,data_base):
        self._DBname = data_base + '.db'
        self.connection = sqlite3.connect(self._DBname,detect_types=sqlite3.PARSE_DECLTYPES,check_same_thread=False,timeout = 10)
        self.cursor = self.connection.cursor()
    
    def close(self):
        self.connection.close()
    
    def create_table(self,command):
        self.cursor.execute(command)
    
    def insert_into_table(self,command,p):
        self.cursor.execute(command,p)
    
    def query_show(self,command):
        self.cursor.execute(command)
        result = self.cursor.fetchone()
        return result
    def query_all(self,command):
        self.cursor.execute(command)
        result = self.cursor.fetchall()
        return result
    def show_tables(self):
        self.cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        a = self.cursor.fetchall()
        if len(a) > 0:
            print([i[0] for i in a])
        else:
            raise EmptyError('The data base is empty!')
    def set_add(new):
        os.chdir(new)
    def commit(self):
        self.connection.commit()
    def initalize(self,path):
        # create tables
        # users table

        sql_command = '''
        CREATE TABLE users (
            user_id CHAR PRIMARY KEY,
            user_name CHAR,
            average_stars CHAR,
            fans INT,
            review_count INT,
            yelping_since CHAR);
        '''

        self.create_table(sql_command)
        print('user set')
        #business table 
        sql_command = '''
        CREATE TABLE business (
            business_id CHAR PRIMARY KEY,
            business_name CHAR,
            long FLOAT,
            lat FLOAT,
            address CHAR,
            stars FLOAT,
            city CHAR,
            state CHAR,
            categories CHAR);
        '''
        self.create_table(sql_command)
        print('business set')
        
        # recommendation table
        sql_command = '''
        CREATE TABLE recommed_factor (
            user_id CHAR,
            business_id CHAR,
            score FLOAT,
            rank INT,
            FOREIGN KEY(user_id) REFERENCES users(user_id),
            FOREIGN KEY(business_id) REFERENCES business(business_id));
        '''
        
        self.create_table(sql_command)
        print('recommend_factor set')
        sql_command = '''
        CREATE TABLE recommed_item (
            user_id CHAR,
            business_id CHAR,
            score FLOAT,
            rank INT,
            FOREIGN KEY(user_id) REFERENCES users(user_id),
            FOREIGN KEY(business_id) REFERENCES business(business_id));
        '''
        
        self.create_table(sql_command)
        print('recommend_item set')
        sql_command = '''
        CREATE TABLE reviews (
            user_id CHAR,
            business_id CHAR,
            text CHAR,
            date CHAR,
            FOREIGN KEY(user_id) REFERENCES users(user_id),
            FOREIGN KEY(business_id) REFERENCES business(business_id));
        '''
        
        self.create_table(sql_command)
        print('reviews set')
        # load in tables
        
        # users
        users = pd.read_csv(path+'/data_table_users.csv',header =0 ,index_col = 0)
                
        command = '''
                INSERT INTO users(user_id,user_name,average_stars,fans,review_count,
                                  yelping_since)
                VALUES (?,?,?,?,?,?)'''
        for i in zip(users['user_id'],users['name'],users['average_stars'],users['fans'],users['review_count'],users['yelping_since']):
            self.insert_into_table(command,i)
        print('users db set')
        del users
        # business
        business = pd.read_csv(path+'/data_table_business.csv',header =0 ,index_col = 0)
        command = '''
                INSERT INTO business(business_id,business_name,long,lat,address,stars,
                city,state,categories)
                VALUES (?,?,?,?,?,?,?,?,?)'''
        for i in zip(*[business[key] for key in business.keys()]):
            self.insert_into_table(command,i)
        del business
        print('business db set')
        # recommendation table
        # factor table
        factor = pd.read_csv(path+'/Factorization_result.csv',header=0, index_col = None)
        command = '''
                INSERT INTO recommed_factor(user_id,business_id,score,rank)
                VALUES (?,?,?,?)'''
        for i in zip(factor['user_id'],factor['business_id'],factor['score'],factor['rank']):
            self.insert_into_table(command,i)
        del factor
        print('factor db set')
        # item table 
        item = pd.read_csv(path+'/item_result.csv',header=0, index_col = None)
        command = '''
                INSERT INTO recommed_item(user_id,business_id,score,rank)
                VALUES (?,?,?,?)'''
        for i in zip(item['user_id'],item['business_id'],item['score'],item['rank']):
            self.insert_into_table(command,i)
        del item
        print('factor db set')
        # reviews
        reviews = pd.read_csv(path+'/data_table_review.csv',header=0)
        command = '''
                INSERT INTO reviews(user_id,business_id,text,date)
                VALUES (?,?,?,?)'''
        for i in zip(reviews['user_id'],reviews['business_id'],reviews['text'],reviews['date']):
            self.insert_into_table(command,i)
        del reviews
        print('reviews set')

        
    def _search_by_userid(self,userid):
        command = '''
                  SELECT recommed_item.user_id,user_name,business_name,address,stars
                  FROM (recommed_item JOIN users ON recommed_item.user_id = users.user_id) T 
                       JOIN business ON T.business_id = business.business_id
                  WHERE T.user_id = \"{user_id}\"
                  LIMIT 10'''.format(user_id = userid)
        return command
        
    def query_userid(self,userid):
        return self.query_all(self._search_by_userid(userid))
    
    def query_users(self,userid,select=2):
        command = '''
                  SELECT *
                  FROM users
                  WHERE users.user_id=\"{user_id}\"
                  '''.format(user_id=userid)
        if select == 2:
            return self.query_all(command)
        else:
            return self.query_show(command)
    def query_review(self,userid,select = 2):
        command = '''
                  SELECT *
                  FROM (reviews LEFT OUTER JOIN users on users.user_id=reviews.user_id) T
                       LEFT OUTER JOIN business on T.business_id = business.business_id
                  WHERE T.user_id=\"{user_id}\"
                  '''.format(user_id=userid)
        if select == 1:
            return self.query_show(command)
        else:
            return self.query_all(command)
    

