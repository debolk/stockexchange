$(document).ready(function(){
  // Compile templates
  var commodity = Handlebars.compile($("#commodity").html());

  // Load commodities
  $.getJSON('/commodities', function(commodities) {
    $(commodities).each(function(){
      $('table tbody').append(commodity(this));
    });
  });

  // Calculate total
  calculate_total();
  $('table').on('keyup', '.amount', calculate_total);

  function calculate_total()
  {
    var total = 0;
    $('tr', 'table tbody').each(function(){
      var amount = $('.amount', this).val();
      var price = $('.price', this).attr('data-value');
      total += amount*price
    });
    $('.total').html((total/100).toFixed(2));
  }
});
