$(document).ready(function(){

  // Create graph
  var data = [];
  var index = 0;  // counter to keep track of the last position added to the graph
  var options = {
    xaxis: {
      show: false,
      tickSize: 1,
    },
    yaxis: {
      show: true,
      min: 0,
      max: 500,
      tickSize: 50,
    },
    grid: {
      borderWidth: 0
    },
    legend: {
      show: false,
    },
    series: {
      lines: {
        lineWidth: 10,
      },
      shadowSize: 0,
    },
  };
  var plot = $.plot('.graphs', data, options);

  // Load commodities
  $.getJSON('/commodities', function(commodities){
    $(commodities).each(function(){
      console.log(this);
      // Create a new data-series
      data.push({
        color: 2 * this.id,
        label: this.name,
        data: [[0, this.bar_price]],
      });

      data.push({
        color: 2 * this.id + 1,
        label: this.name + " - koers",
        data: [[0, this.rate]],
      });

      // Draw the graph
      plot = $.plot('.graphs', data, options);
      // Add price to display
      $('<span>').text(' '+this.name+': ').appendTo('.prices');
      $('<span>').addClass('price').attr('data-id',this.id).html('&euro;'+(parseInt(this.bar_price)/100).toFixed(2)).appendTo('.prices');
    });

    // Start updating prices
    update_prices();
  });

  // Regularly update prices of commodities
  window.update_prices = function()
  {
    // Increase the counter to keep data in line
    index++;

    // Load updated commodities from server
    $.getJSON('/commodities', function(commodities) {
      $(commodities).each(function(){
        // Add a new entry to the data
        var commodity = this;
        $(data).each(function(){
          // Drop an entry if the data-set gets too long
          if (this.data.length > 1000) {
            this.data = this.data.slice(1);
          } 

          if (this.label == commodity.name) {
            // Push new data to stack
            this.data.push([index, commodity.bar_price]);
          } else if (this.label == commodity.name + ' - koers') {
            // Push new data to stack
            this.data.push([index, commodity.rate]);
          }
        });
        // Redraw the graph
        plot = $.plot('.graphs', data, options);
        // Update the price listing 
        $('.price[data-id="'+commodity.id+'"]').html('&euro;'+(parseInt(commodity.bar_price)/100).toFixed(2));
      });
      // Do this 1x per second
      setTimeout('update_prices()', 500);
    });
  }
});
