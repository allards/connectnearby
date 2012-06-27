$(window).ready () ->


    handlePositionError = (error) ->
        switch error
            when error.PERMISSION_DENIED then message = 'Permission denied'
            when error.POSITION_UNAVAILABLE then message = 'Position unavailable'
            when error.TIMEOUT then message = 'GPS timeout'
            else message = 'unknown error'
        $('#gps-message').text('Location: ' + message)    

    handlePositionFound = (position) ->
        user.lat = position.coords.latitude
        user.lon = position.coords.longitude
        # coordinates =  lat.toString() + ' / ' + lon.toString()
        # $('#gps-message').text('Location: ' + coordinates)
        hasLocation = true
        if user.hasUid
            $.post('/register',{uid: user.uid, access_token: user.access_token, lon:user.lon, lat:user.lat}, onRegisterResult)

    getGPS = () ->    
        if navigator.geolocation and user.lat == 0
            # get location
            navigator.geolocation.getCurrentPosition(handlePositionFound, handlePositionError)
        else
            $('#gps-message').text('GPS not enabled')

    getGPS()


    onRegisterResult = (fromServer) ->
        console.log fromServer
        fromServer = jQuery.parseJSON(fromServer)
        html = ''
        for person in fromServer
            html += '<li><a href="http://www.facebook.com/addfriend.php?id=' + person.fb_uid + '" target="add_friend">'
            html +=	'<img src="' + person.pic_big + '" />'
            html +=	'<h3>Add ' + person.name + ' as friend</h3>'
            html +=	'</a></li>'
        $('#people-list').html(html)
        $('#people-list').listview("refresh")
            

    window.register = () ->
        if user.uid
            user.hasUid = true
            if user.hasLocation
                $.post('/register',{uid: window.uid, access_token: window.access_token, lon:lon, lat:lat}, onRegisterResult)

