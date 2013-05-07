$(document).ready(function(){
  // Load commodities
  $.getJSON('/commodities?110F4B0BDF366C453723', function(commodities) {
    $(commodities).each(function(){
      $('<option>').val(this.id).html(this.name).appendTo('#commodity');
      var div = $('<div class="commodity" id="commodity-' + this.name + '">');
      div.append(' \
      <form> \
      <div class="row"><h3>' + this.name + '<h3></div> \
      <div class="row"><input type="number" step="0.01" min="0.1" max="15" name="supply_price" value="' + (this.supply_price / 100).toFixed(2) + '"></div> \
      <div class="row"><input type="number" min="0" max="5" name="supply_rate" value="' + this.supply_rate + '"></div> \
      <div class="row"><input id="update-' + this.name + '" type="button" value="Update"></div> \
      </form> \
      ');
      div.appendTo('#commodities');
      var name = this.name;
      $('#update-' + this.name).on('click', function() {
        var update = {
          "supply_price":
            Math.round($('#commodity-' + name + ' input[name=supply_price]').val() * 100),
          "supply_rate":
            $('#commodity-' + name + ' input[name=supply_rate]').val(),
        };
        $.ajax({
          "url": "/commodities/" + name + "?110F4B0BDF366C453723",
          "data": JSON.stringify(update),
          "method": "PUT",
          });
      });
    });
  });
});
