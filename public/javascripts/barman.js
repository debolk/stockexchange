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
    // Start updating prices (see below)
    // Do this 2x per second
    setInterval('update_prices()', 500);
  });

  // Regularly update prices of commodities
  window.update_prices = function()
  {
    // Load updated commodities from server
    $.getJSON('/commodities', function(commodities) {
      // Update prices
      $(commodities).each(function(){
        var p = (parseInt(this.bar_price) / 100).toFixed(2);
        $('tr[data-id="'+this.id+'"] .price', 'table tbody').html('&euro;'+p);
        $('tr[data-id="'+this.id+'"] .price', 'table tbody').attr('data-value', p * 100);

      });
    });
  }

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

    // Gather data
    var data = [];
    $('input[name="order"]', 'table').each(function(){
      id     = $(this).parents('tr').attr('data-id');
      amount = $(this).val();
      data.push({commodity_id: id, amount: amount});
    });

    // Check for illegal input
    var error = false;
    var regex = /^[0-9]*$/;
    $(data).each(function(){
      if (! regex.test(this.amount)) {
        error = true;
        return false; // Breaks the loop (performance optimization)
      }
    });
    if (error) {
      StockExchange.addAlert('error', 'Illegal input: use only positive integers', true);
    }

    // Submit form
    if (!error) {
      $.ajax({
        method: 'POST',
        url: '/bar_order?110F4B0BDF366C453723', 
        data: JSON.stringify(data), 
        success: function(result) {
          StockExchange.addAlert('success', 'Order saved', true);
          $('input[name="order"]', 'table').val('');
        },
        contentType: 'json',
      });
    }
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
