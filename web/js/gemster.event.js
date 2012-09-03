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


function getParameterByName(name)
{
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regexS = "[\\?&]" + name + "=([^&#]*)";
    var regex = new RegExp(regexS);
    var results = regex.exec(window.location.search);
    if(results == null)
        return "";
    else
        return decodeURIComponent(results[1].replace(/\+/g, " "));
}

function onLoadData(data) {

    var results = data.records;
    var size = results.length;

    var div = '';

    for (var i = 0; i < 3; i++) {

        var randomnumber=Math.floor(Math.random()*results.length);

        var e = results[randomnumber];

        div += '<a href="/facebook/event_page.php?eid=' + e.eid + '"><div style="width: 282px; height: 93px; border-bottom: 1px solid lightGray; ">';

        div += '<div style="width: 100%; height: 68px; border: 0px solid green;">';
        div += '<div id="img" style="width: 64px; height: 64px; overflow: hidden; border: 1px solid gray; margin: 5px 5px 0px 5px; box-shadow: 0px 2px 2px #888; float: left;">';
        div += '<img src="' + e.pic_big + '" alt="other event picture" style="min-width: 100%;" />';
        div += '</div>';

        var name = e.name;
        var location = e.location;

        if (name.length > 22) {
            name = name.substr(0, 19) + '...';
        }

        if (location.length > 22) {
            location = location.substr(0, 19) + '...';
        }

        div += '<div id="info" style="float: left; padding-left: 10px; padding-top: 10px;">';
        div += '<span style="">' + name + '</span><br />';
        div += '<span style="">' + location + '</span><br />';
        div += '<div id="score" style="margin-top: 8px;">';
        for (var j = 0; j < 5; j++) {
            var imgStr = '<img src="../img/diamondSlot.png" alt="diamond slot" style="width: 24px; height: 18px;" />';
            if (j < e.score) {
                imgStr = '<img src="../img/diamond.png" alt="diamond slot" style="width: 24px; height: 18px;" />';
            }
            div += imgStr;
        }
        div += '</div>';

        div += '</div>';
        div += '</div>'

        div += '<div style="width: 100%; height: 30px; font-size: 10px; color: gray; border: 0px solid blue; margin-top: 8px; margin-left: 5px;">';
        div += '<div style="width: 49%; text-align: left; float: left; border: 0px solid red;">' + e.date_start + '@' + e.time_start + '</div>';
        div += '<div style="width: 49%; text-align: right; float: left; border: 0px solid red;">' + e.distance + ' mi.</div>';
        div += '</div>';

        div += '</div></a>'
    }

    return div;
}