particlesJS('splash-bg', {
  particles: {
    color: '#fff',
    shape: 'triangle',
    opacity: 1,
    size: 2,
    size_random: false,
    nb: $(window).width() / 5,
    line_linked: {
      enable_auto: true,
      distance: 100,
      color: '#fff',
      opacity: 0.9,
      widapp: 1,
      condensed_mode: {
        enable: false,
        rotateX: 600,
        rotateY: 600
      }
    },
    anim: {
      enable: true,
      speed: 1
    }
  },
  interactivity: {
    enable: false
  },
  retina_detect: true
});

window.app = {};

app.auth = {};

app.auth.render = function() {
  return gapi.signin.render('googleSignIn', {
    callback: 'signInCallback',
    clientid: '70162173884-17kl5i9qdhkj5qbrj3ds4bpg573dg5h0.apps.googleusercontent.com',
    cookiepolicy: 'single_host_origin',
    scope: 'profile'
  });
};

app.auth.callback = function(authRes) {
  $('#googleSignIn').hide();
  return $.post('/api/login', {
    singleUseToken: authRes.code
  }, function(res) {
    app.auth.loggedIn = true;
    return app.update.profile();
  });
};

app.auth.loggedIn = false;

(function() {
  var po, s;
  window.render = app.auth.render;
  window.signInCallback = app.auth.callback;
  po = document.createElement('script');
  po.type = 'text/javascript';
  po.async = true;
  po.src = 'https://apis.google.com/js/client:plusone.js?onload=render';
  s = document.getElementsByTagName('script')[0];
  return s.parentNode.insertBefore(po, s);
})();

app.profile = {};

app.profile.formHandler = function() {
  return $.ajax({
    type: 'PUT',
    url: '/api/me',
    data: $('#profile-form').serialize(),
    success: app.update.profile
  });
};

$('#profile-form').submit(function(e) {
  app.profile.formHandler();
  return e.preventDefault();
});

Handlebars.registerHelper('toLowerCase', function(val) {
  if (val != null) {
    return new Handlebars.SafeString(val.toLowerCase());
  } else {
    return '';
  }
});

app.templates = {
  announcements: Handlebars.compile($("#announcements-template").html()),
  people: null
};

app.init = function() {
  $("#announcements").html(app.templates.announcements({
    announcements: []
  }));
  return app.update.all();
};

app.update = {
  announcements: function(data) {
    data = data.sort(function(a, b) {
      return a.timestamp - b.timestamp;
    }).map(function(elem) {
      elem.timestamp = moment(elem.timestamp, 'x').fromNow();
      return elem;
    }).slice(-5);
    return $("#announcements").html(app.templates.announcements({
      announcements: data
    }));
  },
  profile: function() {
    if (app.auth.loggedIn) {
      return $.get('/api/me', null, function(data) {
        var update;
        if ((data != null) && data !== '') {
          data = JSON.parse(data);
          update = function(keyword) {
            if (data[keyword] != null) {
              return $("input[name=" + keyword + "]").val(data[keyword]);
            }
          };
          update('firstName');
          update('lastName');
          update('email');
          update('github');
          update('url');
          update('pastHackathons');
          update('linkedIn');
          update('age');
          update('major');
          update('school');
          return update('year');
        }
      });
    }
  },
  all: function() {
    return app.update.profile();
  }
};

$(window).on('ready', app.init());
