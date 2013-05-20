$(document).ready(function(){
  // Ask for confirmation
  $('button').on('click', function(event){
    event.preventDefault();
    if (confirm('Are you really sure?')) {
      $.ajax({
        url: '/close?110F4B0BDF366C453723',
        type: 'delete',
        success: function() {
          StockExchange.addAlert('success', 'Markets are closed', true);
        }
      });
    }
  })
});
