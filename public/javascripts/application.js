$(document).ready(function(){
  // Handlebars-helper to format dates
  Handlebars.registerHelper('money', function(item) {
    return new Handlebars.SafeString('&euro;'+(parseInt(item)/100).toFixed(2));
  });

  // Setup common ajax logic
  $.ajaxSetup({
    error: function(jqXHR, textStatus, errorThrown) {
      // Decide between mega-errors and normal errors
      if (jqXHR.status == 503) {
        // Show a mega-error
        $('#alert-mega').text(jqXHR.responseText);
        $('#alert-mega, #mega-overlay').show();
        track_errors();
      }
      else {
        // Show a regular error
        StockExchange.addAlert('error', jqXHR.responseText);
      }
    },
  });

  window.track_errors = function()
  {
    $.get('/status',function(response) {
      if (response == 'normal') {
        // Resume normal operations
        $('#alert-mega, #mega-overlay').hide();
        window.location.reload();
      }
      else {
        // Keep scanning
        setTimeout('track_errors()', 3000);
      }
    });
  }

  // Global object for logic and stuffz
  window.StockExchange = {
    clearAlerts: function() {
      $('.alerts').empty()
    },
    addAlert: function(type, text, remove_previous) {
      // Default arguments provided
      if(typeof(remove_previous)==='undefined') {
        remove_previous = false;
      }

      // Clear alerts if asked
      if (remove_previous) {
        this.clearAlerts();
      }
      $('<div>').addClass('alert alert-'+type).html(text).appendTo('.alerts')
    },
  };
});
