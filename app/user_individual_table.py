# -*- coding: utf-8 -*-
from datetime import datetime, timedelta
from ipykernel import kernelapp as app
from datetime import datetime as dt
from ggplot import *
from plotly.graph_objs import *
from plotly.tools import FigureFactory as FF
from os import path
from plotly import tools
import numpy as np
import pandas as pd
import plotly 
import plotly.plotly as py
import plotly.tools as tls   
import plotly.graph_objs as go
import plotly.offline as offline
import os
import recommenderDB

{"username": "ruifancu",
 "stream_ids": ["ylosqsyet5", "h2ct8btk1s", "oxz4fm883b"],
 "api_key": "rVs2jjBO7srf2gpv7EuJ"
}
plotly.tools.set_credentials_file(username='valenese', api_key='ty7vvT737UtCO7ssYvDF')


# In[72]:

#user = pd.read_csv('yelp_academic_dataset_user.csv')
#user.head()
t= recommenderDB.minidatabase('recommend')
user_new = t.query_users('1diI7PX0AxbbtiUB7nPbuQ')

user_new = user_new[0]

user_new = pd.DataFrame([{'user_id':user_new[0],'name':user_new[1],'average_stars':user_new[2],'fans':user_new[3],'review_count':user_new[4],'yelping_since':user_new[5]}],)

#user_new = user[['user_id','average_stars','fans','review_count','yelping_since']]
#user_new['yelping_since'].dtype


# In[73]:

## Convert yelp sinc into the length this user has being registed in yelp
user_new.loc[:,'yelping_since_date'] = pd.to_datetime(user_new.loc[:,'yelping_since'], format = "%Y-%m")
user_new.loc[:,'year'] = user_new.loc[:,'yelping_since_date'].dt.year
user_new.loc[:,'month'] = user_new.loc[:,'yelping_since_date'].dt.month
now = datetime.today()
print(now)
today_year = now.year
today_month = now.month
today_month
user_new.loc[:,'TimeLength'] = (today_year-user_new.loc[:,'year'])*12+(today_month-user_new.loc[:,'month'])
user_new.loc[:,'CountFreq'] = user_new.loc[:,'review_count'] / user_new.loc[:,'TimeLength']
user_new.loc[:,'CountFreq'] = user_new.loc[:,'CountFreq'].round(2)
user_new.head()


# In[74]:

## Define ethe function 
# userid = "rpOyqD_893cqmDAtJLbdog"
# def user_info (userid):
result_table = user_new.loc[:,['user_id','average_stars','review_count','fans','CountFreq']]
means = ['Mean', 3.75, 25.76, 1.29, 0.44]
         #round(np.mean(result_table.loc[:,"average_stars"]),2),
         #round(np.mean(result_table.loc[:,"review_count"]),2),
         #round(np.mean(result_table.loc[:,"fans"]),2),
         #round(np.mean(result_table.loc[:,"CountFreq"]),2)]
median = ['Median', 3.92, 5.0, 0.0, 0.14]
        #round(np.median(float(result_table.loc[:,"average_stars"])),2),
        #round(np.median(result_table.loc[:,"review_count"]),2),
        #round(np.median(result_table.loc[:,"fans"]),2),
        #round(np.median(result_table.loc[:,"CountFreq"]),2)]

Mean = pd.DataFrame([means, median], 
                        columns=list(['user_id','average_stars','review_count','fans','CountFreq']))
#print(Mean)
#result_table.head()


# In[75]:
# Table
def user_info_table (userid) :
    result = result_table.loc[result_table.loc[:,'user_id'] == userid,:]
    result = result.append(Mean,ignore_index=True)
    result.columns = ['user_id','Average Stars','Review Count','Number of Fans','Count per Month']
    result.set_index("user_id", drop=True, inplace=True)
    table = FF.create_table(result, index=True,index_title='User ID')
    table.layout.width=1200
    # cwd = os.getcwd()
    # wc_path = cwd + '/static/images/individual_wc.png'
    # wordcloud.to_file(wc_path)
    #print(result)
    cwd = os.getcwd()
    wc_path = cwd + '/static/images/test/Tebles'+userid+'.png'
    py.image.save_as(table, filename=wc_path)
    t.close()
    return '/static/images/test/Tebles'+userid+'.png'

