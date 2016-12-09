from os import path
import os
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt

from wordcloud import WordCloud, STOPWORDS
import pandas as pd

import recommenderDB

from scipy.misc import imread
food_mask = imread("Yelp_Logo.jpg")

db = recommenderDB.minidatabase('recommend')


def individ_wc(user_id):
    #text_data = review_dataset[review_dataset['user_id'] == user_id]['text'].tolist()
    individual_dataset = db.query_review(user_id)
    a = ''
    for i in range(len(individual_data)):
        a += individual_data[i][2]
        
    wordcloud =  WordCloud(background_color="white", max_words=2000, mask=food_mask,
               stopwords=STOPWORDS.add("food"))
    # generate word cloud
    wordcloud.generate(a)
    cwd = os.getcwd()
    wc_path = cwd + '/static/images/individual_wc.png'
    wordcloud.to_file(wc_path)

    #print(cwd)


    #print(wc_path)
    db.close()
    return '/static/images/individual_wc.png'


#individ_wc('qEE5EvV-f-s7yHC0Z4ydJQ')