$(document).ready(function(){
  // Compile templates
  var open_order = Handlebars.compile($("#open_order").html());
  var matched_order = Handlebars.compile($("#matched_order").html());

  // Load commodities
  $.getJSON('/commodities', function(commodities) {
    $(commodities).each(function(){
      $('<option>').val(this.name).html(this.name).appendTo('#commodity');
    });
  });

  window.load_orders = function(){
    // Load orders
    $.getJSON('/buy_orders', function(buy_orders) {
      $('#matched_orders tbody').empty();
      $('#open_orders tbody').empty();
      $(buy_orders).each(function() {
        if (this.state == 'matched') {
          $('#matched_orders tbody').append(matched_order(this));
        }
        else {
          $('#open_orders tbody').append(open_order(this));
        }
      });
    });
  };
  window.load_orders();
  
  setInterval('window.load_orders()', 2000);
  
  // Select all checkbox
  $('input.all').on('click', function(){
    var table = $(this).parents('table');
    $('tbody input[type="checkbox"]', table).prop('checked', $(this).is(':checked'));
  });

  // Confirm action
  $('#matched_orders').on('click', '.confirm', function(event){
    event.preventDefault();
    if (!confirm('Are you sure?')) {
      return;
    }
    var row = $(this).parents('tr');
    $.ajax({
      type: 'PUT',
      url: '/buy_orders/'+row.attr('data-id')+'/payment?214E7DD41B7C823DF963',
      contentType: 'application/json',
      success: function(result){
        row.remove();
        StockExchange.addAlert('success', 'Buy order confirmed', true);
        window.load_orders();
      },
      error: function() {
        alert('Something went wrong. Please try again or reload');
      },
    });
  });

  // Submit form
  $('form').on('submit', function(event){
    event.preventDefault();
    var data = {
      commodity: $('[name="commodity"]').val(),
      amount: $('[name="amount"]').val(),
      price: $('[name="price"]').val(),
      phone: '316'+$('[name="phone"]').val(),
      owner: $('[name="owner"]').val(),
    }
    $.ajax({
      method: 'POST',
      url: '/buy_orders?214E7DD41B7C823DF963', 
      data: JSON.stringify(data), 
      success: function(result) {
        StockExchange.addAlert('success', 'Buy order added', true);
        $('#open_orders tbody').append(open_order(result)); // Append to body
        window.load_orders();
      },
      contentType: 'json',
      dataType: 'json',
    });
  });

  // Destroy order
  $('.orders').on('click', '.destroy', function(event){
    event.preventDefault();
    if (!confirm('Are you sure?')) {
      return;
    }
    var row = $(this).parents('tr');
    $.ajax({
      type: 'DELETE',
      url: '/buy_orders/'+row.attr('data-id')+'?214E7DD41B7C823DF963',
      success: function(){
        StockExchange.addAlert('success', 'Order removed', true);
        row.remove();
      },
    });
  });
});
