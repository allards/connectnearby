(function() {

  $(window).ready(function() {
    var getGPS, handlePositionError, handlePositionFound, onRegisterResult;
    handlePositionError = function(error) {
      var message;
      switch (error) {
        case error.PERMISSION_DENIED:
          message = 'Permission denied';
          break;
        case error.POSITION_UNAVAILABLE:
          message = 'Position unavailable';
          break;
        case error.TIMEOUT:
          message = 'GPS timeout';
          break;
        default:
          message = 'unknown error';
      }
      return $('#gps-message').text('Location: ' + message);
    };
    handlePositionFound = function(position) {
      var hasLocation;
      user.lat = position.coords.latitude;
      user.lon = position.coords.longitude;
      hasLocation = true;
      if (user.hasUid) {
        return $.post('/register', {
          uid: user.uid,
          access_token: user.access_token,
          lon: user.lon,
          lat: user.lat
        }, onRegisterResult);
      }
    };
    getGPS = function() {
      if (navigator.geolocation && user.lat === 0) {
        return navigator.geolocation.getCurrentPosition(handlePositionFound, handlePositionError);
      } else {
        return $('#gps-message').text('GPS not enabled');
      }
    };
    getGPS();
    onRegisterResult = function(fromServer) {
      var html, person, _i, _len;
      console.log(fromServer);
      fromServer = jQuery.parseJSON(fromServer);
      html = '';
      for (_i = 0, _len = fromServer.length; _i < _len; _i++) {
        person = fromServer[_i];
        html += '<li><a href="http://www.facebook.com/addfriend.php?id=' + person.fb_uid + '" target="add_friend">';
        html += '<img src="' + person.pic_big + '" />';
        html += '<h3>Add ' + person.name + ' as friend</h3>';
        html += '</a></li>';
      }
      $('#people-list').html(html);
      return $('#people-list').listview("refresh");
    };
    return window.register = function() {
      if (user.uid) {
        user.hasUid = true;
        if (user.hasLocation) {
          return $.post('/register', {
            uid: window.uid,
            access_token: window.access_token,
            lon: lon,
            lat: lat
          }, onRegisterResult);
        }
      }
    };
  });

}).call(this);
