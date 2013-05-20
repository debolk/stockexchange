$(document).ready(function(){
  // Compile templates
  var open_order = Handlebars.compile($("#open_order").html());

  // Function to load new orders from the server
  window.load_orders = function(){
    $.getJSON('/buy_orders', function(buy_orders) {
      // Empty the table
      $('#open_orders tbody').empty();
      
      // Insert new orders
      $(buy_orders).each(function() {
        $('#open_orders tbody').append(open_order(this));
      });
      
      // Load new orders after a second
      setTimeout('window.load_orders()', 1000);
    });
  };

  // Start loading orders
  window.load_orders();
});
