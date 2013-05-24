$(document).ready(function(){

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
});
