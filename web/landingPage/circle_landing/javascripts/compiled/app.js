function toggleScreens(shows, hides) {
  var show = $("div#state_" + shows);
  var hide = $("div#state_" + hides);
  hide.fadeToggle('fast', function() {
    show.fadeToggle('fast');
  });
}

$(function() {
  if (isIphone() || isAndroid()) {
    window.location = "/download/";
    return true;
  }

  $("div#state_welcome a.sms").click(function() {
    toggleScreens("sms", "welcome");
    return false;
  });
  $("div#state_sms a.close").click(function() {
    toggleScreens("welcome", "sms");
    return false;
  });
  $("div#state_sms a.sms").click(function() {
    var val = $("div#state_sms input").val();
    $.ajax({
      url: '/api/external/sms',
      type: 'post',
      data: {
        cell: val
      },
      beforeSend: function() {
        $("div#state_sms").addClass("sending");
        $("div#state_sms label").html("Sending to " + val + " ...");
      },
      success: function() {
        $("div#state_welcome h2").html('Sent. One more?');
        $("div#state_sms label").html("Change your number/email?");
        toggleScreens("welcome", "sms");
      },
      error: function(xhr, status, error) {
        $("div#state_sms label").html("Error. Check number/email?");
      },
      complete: function() {
        $("div#state_sms").removeClass("sending");
      }
    });
  });
  setPlaceHolders();
});

function recordOutboundLink(self, action, state) {
  console.log("outbound link: " + action + " => " + state);
  // TODO(@hrushikesh): Add analytics.
}

function setPlaceHolders() {
  $('[c_placeholder]').focus(function() {
    var input = $(this);
    if (input.val() == input.attr('c_placeholder')) {
      input.val('');
    }
  }).blur(function() {
    var input = $(this);
    if (input.val() == '' || input.val() == input.attr('c_placeholder')) {
      input.val(input.attr('c_placeholder'));
    }
  }).blur();
}



// Legacy code generated by coffeescript.
(function() {
  var gid, _ref;
  if ((_ref = window.console) == null) {
    window.console = {
      log: function() {}
    };
  }
  gid = function(el) {
    return document.getElementById(el);
  };
  $(function() {
    var $slide_nav, sliderHandler, sliderSetup;
    $slide_nav = $("#slide_nav");
    sliderHandler = function(ev, idx, el) {
      var $arrow_left, $changeColor, colour, colours, _i, _len;
      $slide_nav.find(".selected").removeClass("selected");
      $slide_nav.find("[data-id='" + idx + "']").addClass("selected");
      if (textSlider.index !== idx) {
        textSlider.slide(idx);
      }
      $changeColor = $(".dl_button, .slide_nav");
      colours = [null, "purple", "blue", "red"];
      for (_i = 0, _len = colours.length; _i < _len; _i++) {
        colour = colours[_i];
        $changeColor.removeClass(colour);
      }
      if (colours[idx]) {
        $changeColor.addClass(colours[idx]);
      }
      $arrow_left = $(".arrow_left");
      if (idx !== 0) {
        return $arrow_left.fadeIn("slow");
      }
    };
    sliderSetup = function() {
      var $slide_text, $slider, arrSlides, cls, defaultOpts, htmlStr, i, slide, sliderOpts, textSliderOpts, _len;
      if (window.Swipe) {
        window.screenSlider = new Swipe(gid('slider'), {
          callback: function(ev, idx, el) {},
          width: 366
        });
        $("#slider").bind("slideEvent", function(ev, idx) {
          return sliderHandler(ev, idx);
        });
        if (window.innerWidth > 480) {
          window.textSlider = new Trans(gid('slide_text'));
        } else if (window.innerWidth <= 480) {
          window.textSlider = new Swipe(gid('slide_text'), {
            callback: function(ev, idx, el) {
              return sliderHandler(ev, idx);
            }
          });
        }
      } else if ($.Widget) {
        $slide_text = $('#slide_text ul');
        $slider = $('#slider ul');
        defaultOpts = {
          slide: {
            interval: 300
          },
          pagination: false,
          navigation: false
        };
        sliderOpts = {
          height: 528,
          width: 366,
          navigateEnd: function(current) {
            screenSlider.index = current - 1;
            return sliderHandler(null, current - 1);
          }
        };
        sliderOpts = $.extend(sliderOpts, defaultOpts);
        textSliderOpts = {
          responsive: true,
          autoHeight: true,
          navigateEnd: function(current) {
            return textSlider.index = current - 1;
          }
        };
        textSliderOpts = $.extend(textSliderOpts, defaultOpts);
        $slider.slides(sliderOpts);
        $slide_text.slides(textSliderOpts);
        window.screenSlider = {
          index: 0,
          length: $slider.slides("status").total,
          next: function() {
            return $slider.slides("next");
          },
          prev: function() {
            return $slider.slides("previous");
          },
          slide: function(idx) {
            return $slider.slides("slide", idx + 1);
          }
        };
        window.textSlider = {
          index: 0,
          length: $slide_text.slides("status").total,
          next: function() {
            return $slide_text.slides("next");
          },
          prev: function() {
            return $slide_text.slides("previous");
          },
          slide: function(idx) {
            return $slide_text.slides("slide", idx + 1);
          }
        };
      }
      htmlStr = "";
      arrSlides = [];
      arrSlides.length = screenSlider.length;
      for (i = 0, _len = arrSlides.length; i < _len; i++) {
        slide = arrSlides[i];
        cls = i === 0 ? "selected" : "";
        htmlStr = htmlStr + ("<li data-id='" + i + "' class='" + cls + "'></li>");
      }
      return $slide_nav.html(htmlStr);
    };
    Modernizr.load({
      test: Modernizr.csstransforms,
      yep: ["circle_landing/javascripts/libs/touch.js", "circle_landing/javascripts/compiled/trans.js", "circle_landing/javascripts/compiled/swipe.js"],
      nope: "circle_landing/javascripts/libs/slide.js",
      complete: function() {
        return sliderSetup();
      }
    });
    $slide_nav.delegate("li", "click", function() {
      var $this, data;
      $this = $(this);
      data = $this.data();
      screenSlider.slide(data.id);
      $slide_nav.find("li").removeClass("selected");
      return $this.addClass("selected");
    });
    $(".arrow_right").show();
    $(".arrow_right").bind("click", function() {
      return screenSlider.next();
    });
    $(".arrow_left").bind("click", function() {
      return screenSlider.prev();
    });
    $("#easter_egg").bind("click", function() {
      return screenSlider.next();
    });
    $(document).bind("keyup", function(e) {
      switch (e.keyCode) {
        case 39:
          return screenSlider.next();
        case 37:
          return screenSlider.prev();
      }
    });
  });
}).call(this);

function isIphone() {
  var agent=navigator.userAgent.toLowerCase();
  return agent.indexOf('iphone')!=-1;
}

function isAndroid() {
  var agent=navigator.userAgent.toLowerCase();
  return agent.indexOf('android')!=-1;
}
