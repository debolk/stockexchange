$(document).ready(function(){
  // Load commodities
  $.getJSON('/commodities', function(commodities) {
    $(commodities).each(function(){
      $('<option>').val(this.name).html(this.name).appendTo('#commodity');
    });
  });

  // Calculate desired price
  $('#commodity').on('change', get_offer);
  $('[name="amount"]').on('keyup', get_offer);

  function get_offer(event)
  {
    event.preventDefault();
    var commodity = $('#commodity').val();
    var amount = $('[name="amount"]').val();
    if (amount.trim() != '') {
      $.ajax({
        type: 'GET',
        url: '/commodities/'+commodity+'/propose?amount='+amount,
        contentType: 'application/json',
        success: function(result){
          var total = parseFloat(result)/100;
          $('[name="total"]').val(total.toFixed(2));
          $('[name="price"]').val((total/amount).toFixed(2));
        },
      });
    }
  }

  // Sell coins
  $('form').on('submit', function(event){
    event.preventDefault();
    var commodity = $('[name="commodity"]').val();
    var amount = $('[name="amount"]').val();
    var price = $('[name="price"]').val();
    if (amount.trim() != '' && price.trim() != '') {
      $.ajax({
        type: 'POST',
        url: '/sell_orders?214E7DD41B7C823DF963',
        data: JSON.stringify({commodity: commodity, amount: amount, price: price}),
        contentType: 'application/json',
        success: function(result){
          StockExchange.addAlert('success', 'Order created', true)
          $('input', 'form').val('');
        },
      });
    }
  });
});
