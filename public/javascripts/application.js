$(document).ready(function(){
  // Handlebars-helper to format dates
  Handlebars.registerHelper('money', function(item) {
    return new Handlebars.SafeString('&euro;'+(parseInt(item)/100).toFixed(2));
  });

  // Setup common ajax logic
  $.ajaxSetup({
    error: function(jqXHR, textStatus, errorThrown) {
      StockExchange.addAlert('error', jqXHR.responseText);
    },
  });

  // Global object for logic and stuffz
  window.StockExchange = {
    clearAlerts: function() {
      $('.alerts').empty()
    },
    addAlert: function(type, text, remove_previous = false) {
      if (remove_previous) {
        this.clearAlerts();
      }
      $('<div>').addClass('alert alert-'+type).html(text).appendTo('.alerts')
    },
  };
});
