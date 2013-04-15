$(document).ready(function(){
  // Compile templates
  var commodity = Handlebars.compile($("#commodity").html());

  // Load commodities
  $.getJSON('/commodities', function(commodities) {
    $(commodities).each(function(){
      $('table tbody').append(commodity(this));
    });
    // Append index numbers
    $('tbody .index').each(function(index){
      $(this).text('F'+(index+1));
    });
  });

  // Calculate total
  calculate_total();
  $('table').on('keyup', '.amount', calculate_total);

  // Key handlers
  $(document).on('keyup', function(event){
    event.preventDefault();
    switch (event.keyCode)
    {
      // Switch to a different field
      case 112: focus_field(0); break; // F1
      case 113: focus_field(1); break; // F2
      case 114: focus_field(2); break; // F3
      case 115: focus_field(3); break; // F4
      // Submit
      case 120: $('form').submit(); break; // F9
    }
  });

  // Submit form
  $('form').on('submit', function(event){
    event.preventDefault();
    alert('To be implemented!');
    // var data = {
    //   commodity: $('[name="commodity"]').val(),
    //   amount: $('[name="amount"]').val(),
    //   price: $('[name="price"]').val(),
    //   phone: $('[name="phone"]').val(),
    // }
    // $.ajax({
    //   method: 'POST',
    //   url: '/buy_orders?214E7DD41B7C823DF963', 
    //   data: JSON.stringify(data), 
    //   success: function(result) {
    //     StockExchange.addAlert('success', 'Buy order added', true);
    //     $('#open_orders tbody').append(open_order(result)); // Append to body
    //   },
    //   contentType: 'json',
    //   dataType: 'json',
    // });
  });

  function focus_field(focus_index)
  {
    $('tbody input[type="number"]').each(function(field_index){
      if (focus_index === field_index) {
        $(this).focus();
      }
    });
  }

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
