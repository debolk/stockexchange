$(document).ready(function(){
  // Compile templates
  var commodity_template = Handlebars.compile($("#commodity_template").html());

  // Load commodities
  $.getJSON('/commodities', function(commodities) {
    $(commodities).each(function(){
      $('<option>').val(this.name).html(this.name).appendTo('#commodity');
    });
  });

  // Adding supply using the form
  $('form').on('submit', function(event){
    event.preventDefault();

    $.ajax({
      url: '/commodities/' + $('#commodity').val() + '?110F4B0BDF366C453723',
      method: 'PUT',
      data: JSON.stringify({
        price: $('#price').val(),
        amount: $('#amount').val(),
        spread: $('#spread').val(),
      }),
      success: function(result){
        StockExchange.addAlert('success', 'Supply added', true);
      },
    });
  });

  // Populate and update statistics
  window.update_statistics = function(){
    $.getJSON('/commodities?110F4B0BDF366C453723', function(commodities) {
      $('table tbody').empty();
      $(commodities).each(function(){
        $('table tbody').append(commodity_template(this));
      });
    });
  };
  setInterval('window.update_statistics()', 5000);
});
