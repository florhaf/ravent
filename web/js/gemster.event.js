google.load("maps", "3",  {callback: initialize, other_params:"sensor=false"});

function initialize() {
    // Initialize default values
    var zoom = 3;
    var latlng = new google.maps.LatLng(37.4419, -100.1419);
    var location = "Showing default location for map.";

    // If ClientLocation was filled in by the loader, use that info instead
    if (google.loader.ClientLocation) {
        zoom = 13;
        latlng = new google.maps.LatLng(google.loader.ClientLocation.latitude, google.loader.ClientLocation.longitude);
        location = "Showing IP-based location: <b>" + getFormattedLocation() + "</b>";
    }

    var myOptions = {
        zoom: zoom,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    }

    //var map = new google.maps.Map(document.getElementById("map"), myOptions);
    //document.getElementById("location").innerHTML = location;
}

function getFormattedLocation() {
    if (google.loader.ClientLocation.address.country_code == "US" &&
        google.loader.ClientLocation.address.region) {
        return google.loader.ClientLocation.address.city + ", "
            + google.loader.ClientLocation.address.region.toUpperCase();
    } else {
        return  google.loader.ClientLocation.address.city + ", "
            + google.loader.ClientLocation.address.country_code;
    }
}

function onLoadData(data) {

    var results = data.records;
    var size = results.length;

    var div = '<div style="margin-top: 18px;">';

    for (var i = 0; i < 3; i++) {

        var randomnumber=Math.floor(Math.random()*results.length);

        var e = results[randomnumber];

        var name = e.name;
        var location = e.location;

        if (name.length > 36) {
            name = name.substr(0, 33) + '...';
        }

        if (location.length > 22) {
            location = location.substr(0, 19) + '...';
        }

        div += '<a href="/facebook/event_page.php?eid=' + e.eid + '" target="_parent"><div style="width: 300px; height: 136px; background-image: url(../img/cellItemEvent.png); background-repeat: no-repeat; border: 0px solid red; margin-top: -7px;">';

            div += '<div style="">';
                div += '<span style="margin-left: 10px; font-size: 14px; font-weight: bold; color: #8399a9; white-space: nowrap;overflow: hidden; width: 280px;">' + name + '</span><br />';
            div += '</div>';

            div += '<div id="img" style="width: 86px; height: 86px; overflow: hidden; border: 0px solid gray; float: left; margin: 8px;">';
                div += '<img src="' + e.pic_big + '" alt="other event picture" style="min-width: 100%;" />';
            div += '</div>';



            div += '<div id="info" style="border: 0px solid orange; width: 198px; margin-top: 6px; float: right; ">';

                div += '<span style="font-weight: bold; margin-left: 22px;">' + location + '</span><br />';
                div += '<span style="margin-left: 22px; font-size: 11px;">' + e.date_start + '</div>';
                div += '<span style="margin-left: 22px; font-size: 11px;">' + e.time_start; + '</div>';


                div += '<div id="score" style="margin-top: 10px;  border: 0px solid yellow;">';
                    for (var j = 0; j < 5; j++) {
                        var imgStr = '<img src="../img/diamondSlot.png" alt="diamond slot" style="width: 24px; height: 18px;" />';
                        if (j < e.score) {
                            imgStr = '<img src="../img/diamond.png" alt="diamond slot" style="width: 24px; height: 18px;" />';
                        }
                        div += imgStr;
                    }
                div += '</div>';

                div += '<div style="width: 50%; text-align: right; float: right; border: 0px solid red; font-size: 10px; padding-right: 12px; margin-top: 8px;">' + e.distance + ' mi.</div>';

            div += '</div>';




        div += '</div></a>'
    }

    div += '</div>';

    return div;
}