//= require jquery
//= require jquery_ujs
//= require_directory

var formHandler = function() {
    $('input').each(function() {
        if($(this).val() == this.defaultValue) {
            $(this).addClass('inactive');
        }
    });

    $('input.inactive').live('focus', function() {
        $(this).removeClass('inactive');
        this.value = '';
    });

    $('input').blur(function() {
        if($(this).val().match(/^\s*$/)) {
            $(this).addClass('inactive');
            this.value = this.defaultValue;
        }
    });

    $('#submit').click(function() {
        if($('input.inactive').length == 0) {
            window.location = '/' + $('#user').val() + '/' + $('#project').val();
        }

        return false;
    });
}

var updatePage = function(github_project) {
  var pageUpdater = function() {
    $.ajax('/' + github_project + '/uptodate', {
      'success': function(data) {
        if(data.uptodate) {
          location.reload();
        } else {
          setTimeout(pageUpdater, 10000);
        }
      }
    });
  }
  pageUpdater();
};
