$(document).ready(function(){
  // Compile templates
  var open_buy_order = Handlebars.compile($("#open_buy_order").html());
  var open_sell_order = Handlebars.compile($("#open_sell_order").html());

  // Function to load new orders from the server
  window.load_orders = function(){

    // Load buy orders
    var buy_call = $.getJSON('/buy_orders', function(buy_orders) {
      $('#buy_orders tbody').empty();
      $(buy_orders).each(function() {
        $('#buy_orders tbody').append(open_buy_order(this));
      });
    });

    // Load sell orders
    var sell_call = $.getJSON('/sell_orders', function(sell_orders) {
      $('#sell_orders tbody').empty();
      $(sell_orders).each(function() {
        $('#sell_orders tbody').append(open_sell_order(this));
      });
    });

    // Wait a second after loading before updating again
    $.when(buy_call, sell_call).then(function(){
      setTimeout('window.load_orders()', 1000);
    });
  };

  // Start loading orders
  window.load_orders();
});
