#!/usr/bin/env python
from gevent import monkey; monkey.patch_all()
import bottle
from bottle import run, route, template, post, request, error, response, redirect, static_file
import pymongo
import json
import utils

con = pymongo.Connection('localhost', 27017, max_pool_size=10)
db = con.oc_connect
bottle.debug(True)

@route('/',)
def index():
    # return 'hello world'
    # will spit out the homepage in html
    return template('index')
    
@route('/register', method='POST', db=db)
def register():
    fb_uid = request.forms.uid
    lon = request.forms.lon
    lat = request.forms.lat
    loc = [float(lon), float(lat)]
    access_token = request.forms.access_token
    url = 'https://api.facebook.com/method/fql.query?query=SELECT+uid%2C+name%2C+pic_big%2C+sex+FROM+user+WHERE+uid+%3D'
    url += fb_uid
    url += '&access_token='
    url += access_token
    url += '&format=json'
    fb_user_data = json.loads(utils.fetch(url))
    if 'error_code' in fb_user_data:
        return 'error'
    else:
        fb_user = fb_user_data[0]
        db.users.update({'fb_uid':fb_uid},{'$set':{'name':fb_user['name'], 'pic_big':fb_user['pic_big'], 'loc':loc}}, True)
        distance = 0.250 # 250 meters
        radians_distance = distance / 6371.0 # the radius of the earth is 6371 km
        cursor = db.users.find({"loc":{"$nearSphere":loc, "$maxDistance": radians_distance}},{'name':1,'fb_uid':1,'pic_big':1}).limit(200)
        nearby = list((record) for record in cursor)
        return utils.jsondumps(nearby)

@route('/unregister', method='POST', db=db)
def unregister():
    fb_uid = request.forms.uid
    access_token = request.forms.access_token
    url = 'https://api.facebook.com/method/fql.query?query=SELECT+uid%2C+name%2C+pic_big%2C+sex+FROM+user+WHERE+uid+%3D'
    url += fb_uid
    url += '&access_token='
    url += access_token
    url += '&format=json'
    fb_user_data = json.loads(utils.fetch(url))    
    if 'error_code' in fb_user_data:
        return 'error'
    else:
        db.users.remove({'fb_uid':fb_uid})
        return 'user removed'

@route('/fbchannel')
def fbchannel():
    # should set client side caching instructions
    # https://developers.facebook.com/blog/post/530/
    return '<script src="//connect.facebook.net/en_US/all.js"></script>'


@route('/static/<filepath:path>')
def server_static(filepath):
    if filepath.endswith('.manifest'):
        return static_file(filepath, root='static', mimetype='text/cache-manifest')
    else:    
        return static_file(filepath, root='static')

@route('/js/<filepath:path>')
def server_js(filepath):
    return static_file(filepath, root='static/js')

@route('/css/<filepath:path>')
def server_css(filepath):
    return static_file(filepath, root='static/css')

@route('/fonts/<filepath:path>')
def server_fonts(filepath):
    return static_file(filepath, root='static/fonts')

@route('/images/<filepath:path>')
def server_images(filepath):
    return static_file(filepath, root='static/images')

@error(404)
def error404(error):
    return 'Error 404: Page not found.'

run(host='0.0.0.0', port=9000, server='gevent')
