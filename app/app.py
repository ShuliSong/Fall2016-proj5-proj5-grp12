from flask import Flask, render_template, jsonify, request

#import ind_user_visual

import word_cloud

import os
#os.chdir() # directory
import recommenderDB 
import user_individual_table
import pandas as pd
import user_individual_barchart
import individual_table


#import requests

app = Flask(__name__)

#db = recommenderDB.minidatabase('recommend')
#db.initalize('/Users/dd/Desktop/app')

@app.route("/homepage")
def home_page():
    return render_template('index.html')

@app.route("/overview")
def overview_page():
    return render_template('no-sidebar.html')

@app.route("/customize")
def customize_page():
    return render_template('left-sidebar.html')

@app.route("/customize/recommend", methods = ['POST'])
def recommend():
	user_id = str(request.form['user_id'])

	#recmd_result = db.query_userid(user_id)

	per = recommenderDB.minidatabase('recommend')
	recmd_result = per.query_userid(user_id)

	per.close()


	#review_dataset = pd.read_csv('yelp_academic_dataset_review.csv')
	#business_dataset = pd.read_csv('yelp_academic_dataset_business.csv')

	plot_sun_1 = individual_table.individ_selfexplore(user_id)


	plot_li_1 = user_individual_table.user_info_table(user_id)

	plot_li_2 = user_individual_barchart.user_info_bars(user_id)

	


	plot_sun_2 = word_cloud.individ_wc(user_id)



	return render_template('recommend.html', user_id = user_id, plot_sun_2 = plot_sun_2, recmd = recmd_result, plot_sun_1 = plot_sun_1, plot_li_1 = plot_li_1, plot_li_2 = plot_li_2)

	#return user_id
	#return render_template('recommend.html', user_id = user_id, plot_sun_2 = plot_sun_2, recmd = recmd_result, plot_li_1 = plot_li_1, plot_sun_1 = plot_sun_1)

	#return render_template('recommend.html', user_id = user_id, recmd = recmd_result)


@app.route("/contact")
def contact_page():
    return render_template('right-sidebar.html')


if __name__ == '__main__':
    app.run(debug=True)