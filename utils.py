import urllib
import urllib2
import Cookie
import json
import datetime
import calendar
from pymongo import objectid

def fetch(url, data=None, headers={},
          cookie=Cookie.SimpleCookie(),
          user_agent='Mozilla/5.0'):
    if data != None:
        data = urllib.urlencode(data)
    if user_agent: headers['User-agent'] = user_agent
    headers['Cookie'] = ' '.join(['%s=%s;'%(c.key,c.value) for c in cookie.values()])
    try:
        from google.appengine.api import urlfetch
    except ImportError:
        req = urllib2.Request(url, data, headers)
        html = urllib2.urlopen(req).read()
    else:
        method = ((data==None) and urlfetch.GET) or urlfetch.POST
        while url is not None:
            response = urlfetch.fetch(url=url, payload=data,
                                      method=method, headers=headers,
                                      allow_truncated=False,follow_redirects=False,
                                      deadline=10)
            # next request will be a get, so no need to send the data again
            data = None
            method = urlfetch.GET
            # load cookies from the response
            cookie.load(response.headers.get('set-cookie', ''))
            url = response.headers.get('location')
        html = response.con
    return html
    
class ComplexEncoder(json.JSONEncoder):
    # class to extend JSON encoding to the datatime.datetime object
    def default(self, obj):
        if isinstance(obj, datetime.datetime):
            # return obj.strftime('%Y-%m-%dT%H:%M:%S')
            # choosing milliseconds since epoch to be compatible with javascript
            return calendar.timegm(obj.timetuple()) * 1000
        if isinstance(obj, objectid.ObjectId):
            return str(obj)
        return json.JSONEncoder.default(self, obj)

def jsondumps (o):
    return json.dumps(o, cls=ComplexEncoder)