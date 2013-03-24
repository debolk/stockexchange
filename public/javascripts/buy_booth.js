$(document).ready(function(){
  // Compile templates
  var order_row = Handlebars.compile($("#order_row").html());

  // Load commodities
  $.getJSON('/commodities', function(commodities) {
    $(commodities).each(function(){
      $('<option>').val(this.id).html(this.name).appendTo('#commodity');
    });
  });
  
  // Load orders
  $.getJSON('/buy_orders', function(buy_orders) {
    $(buy_orders).each(function() {
      var row = order_row(this);
      if (this.state == 'matched') {
        $('#matched_orders tbody').append(row);
      }
      else {
        $('#open_orders tbody').append(row);
      }
    });
  });

  // Select all checkbox
  $('input.all').on('click', function(){
    var table = $(this).parents('table');
    $('tbody input[type="checkbox"]', table).prop('checked', $(this).is(':checked'));
  });
});