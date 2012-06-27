<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Facebook Connect Nearby</title>
    <link rel="stylesheet" href="http://code.jquery.com/mobile/1.1.0/jquery.mobile-1.1.0.min.css" />
    <link media="all" rel="stylesheet" type="text/css" href="css/all.css" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
    <script src="http://code.jquery.com/mobile/1.1.0/jquery.mobile-1.1.0.min.js"></script>
    <script src="/static/js/connect.js"></script>
  </head>
  <body>
    <div id="fb-root"></div>
    <div data-role="page" id="page1">
    <div data-theme="b" data-role="header">
        <h3>
            Connect Nearby
        </h3>
    </div>
    <script>

        var user = new Object();    
        user.lat = 0;
        user.lon = 0;
        user.hasUid = false;
        user.hasLocation = false;

        // Load the SDK Asynchronously
        (function(d){
         var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
         if (d.getElementById(id)) {return;}
         js = d.createElement('script'); js.id = id; js.async = true;
         js.src = "//connect.facebook.net/en_US/all.js";
         ref.parentNode.insertBefore(js, ref);
        }(document));

        // Init the SDK upon load
        window.fbAsyncInit = function() {
        FB.init({
          appId      : '178243285639835', // App ID
          channelUrl : '//'+window.location.hostname+'/fbchannel', // Path to your Channel File
          status     : true, // check login status
          cookie     : true, // enable cookies to allow the server to access the session
          xfbml      : true  // parse XFBML
        });

        // listen for and handle auth.statusChange events
        FB.Event.subscribe('auth.statusChange', function(response) {
          if (response.authResponse) {
            // user has auth'd your app and is logged into Facebook
            FB.api('/me', function(me){
              if (me.name) {
                document.getElementById('auth-displayname').innerHTML = me.name;
                user.uid = me.id;
                user.access_token = response.authResponse.accessToken;
                register();
              }
            })
            document.getElementById('auth-loggedout').style.display = 'none';
            document.getElementById('auth-loggedin').style.display = 'block';
          } else {
            // user has not auth'd your app, or is not logged into Facebook
            document.getElementById('auth-loggedout').style.display = 'block';
            document.getElementById('auth-loggedin').style.display = 'none';
          }
        });

        // respond to clicks on the login and logout links
        document.getElementById('auth-loginlink').addEventListener('click', function(){
          FB.login();
        });
        document.getElementById('auth-logoutlink').addEventListener('click', function(){
          FB.logout();
          console.log('going to unregister');
          $.post('/unregister',{uid: user.uid, access_token: user.access_token});
        }); 
        } 
    </script>
      <div id="auth-status">
        <div id="auth-loggedout">
          Log in at <a href="#" id="auth-loginlink">Facebook</a> to find people nearby. 
        </div>
        <div id="auth-loggedin" style="display:none">
          You are logged in as <span id="auth-displayname"></span>  
        (<a href="#" id="auth-logoutlink">logout</a>)
      </div>
      <div id="gps-message"></div>
    </div>
		<div class="content-primary">	
		<ul id="people-list" data-role="listview">
		</ul>
	</div>
	<div id="help-message">
	    People above have this page connect.othercircles.com open, are signed with Facebook and are nearby.
	<div>
  </body>
</html>


