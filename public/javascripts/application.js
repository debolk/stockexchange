$(document).ready(function(){
  // Load commodities
  $.getJSON('/commodities', function(commodities) {
    $(commodities).each(function(){
      $('<option>').val(this.id).html(this.name).appendTo('#commodity');
    });
  });
});