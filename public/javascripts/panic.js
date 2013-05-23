$(document).ready(function(){
  // Ask for confirmation
  $('button').on('click', function(event){
    event.preventDefault();
    if (confirm('Are you really sure?')) {
      $.ajax({
        url: '/panic?110F4B0BDF366C453723',
        type: 'delete',
        success: function() {
          StockExchange.addAlert('success', 'Markets are in panic', true);
        }
      });
    }
  })
});
