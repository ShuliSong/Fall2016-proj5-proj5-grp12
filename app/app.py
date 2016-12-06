from flask import Flask, render_template, jsonify, request
import requests

app = Flask(__name__)

@app.route("/homepage")
def home_page():
    return render_template('index.html')

@app.route("/overview")
def overview_page():
    return render_template('no-sidebar.html')

@app.route("/customize")
def customize_page():
    return render_template('left-sidebar.html')

@app.route("/contact")
def contact_page():
    return render_template('right-sidebar.html')


if __name__ == '__main__':
    app.run(debug=True)