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
});
