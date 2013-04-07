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
    contentType: 'json',
    dataType: 'json',
  });

  // Global object for logic and stuffz
  window.StockExchange = {
    clearAlerts: function() {
      $('.alerts').empty()
    },
    addAlert: function(type, text) {
      $('<div>').addClass('alert alert-'+type).html(text).appendTo('.alerts')
    },
  };
});
