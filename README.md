connectnearby
=============

Facebook Find Friends Nearby Clone
This little HTML5 app should run in modern desktop and mobile browsers. The app will show people who have surfed to the app's homepage, have logged with Facebook and are physically nearby. It can be an easier way for adding someone you are meeting as a Facebook friend. You can see the app in action here:
http://connect.othercircles.com

Server-side code is in Python and uses bottle.py. The example uses Gevent and assumes you would be proxying with something like Nginx.

Persistent storage is MongoDB. To be able to determine who is nearby you need to run:
db.users.ensureIndex({"loc":"2d"})

Front-end is written in Coffeescript/Javascript and uses Mobile JQuery.
