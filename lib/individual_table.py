import numpy as np
import pandas as pd
import plotly.plotly as py
import plotly.graph_objs as go
import plotly.tools as tls
from plotly.tools import FigureFactory as FF 
import os
import recommenderDB

tls.set_credentials_file(username='XuechunSun', api_key='bf4ku25v0j')


title = ['Time','Business names','business categories','City','Stars','Business address']
def individ_selfexplore(user_id):
    db = recommenderDB.minidatabase('recommend')
    individual_data = db.query_review(user_id)
    business_user = []
    business_time = []
    business_name = []
    business_categories = []    
    business_city = []
    business_stars = []
    business_address = []
    for i in range(min(len(individual_data),10)):
        business_user.append(individual_data[i][1])
        business_time.append(individual_data[i][3])
        business_name.append(individual_data[i][11])
        business_categories.append(individual_data[i][18].split(',')[0])
        business_city.append(individual_data[i][16])
        business_stars.append(individual_data[i][15])
        business_address.append(individual_data[i][14])

    individual_info = list(zip(business_time, business_name, business_categories,business_city, business_stars, business_address))
    #individual_info = title.append(individual_info)

    individual_info = np.array(individual_info)
    individual_info = np.insert(individual_info, 0, title, axis=0)
    
    table = FF.create_table(individual_info)
    #table.layout.height = 600
    #individual_plot = py.plot(table, filename='individual_selfexplore')
    table.layout.width = 1700
    cwd = os.getcwd()
    wc_path = cwd + '/static/images/individual_selfexplore.png'
    py.image.save_as(table, filename=wc_path)
    
    db.close()
    return '/static/images/individual_selfexplore.png'

#individ_selfexplore('auESFwWvW42h6alXgFxAXQ')
#print(a)
    
    
