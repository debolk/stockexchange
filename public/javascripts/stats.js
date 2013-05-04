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
      // Add the new data
      data.push({
        color: this.id,
        label: this.name,
        data: [[0, this.bar_price]],
      });
      // Redraw the graph
      plot = $.plot('.graphs', data, options);
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
          if (this.label == commodity.name) {
            // Drop an entry if the data-set gets too long
            if (this.data.length > 10) {
              this.data = this.data.slice(1);
            } 
            // Push new data to stack
            this.data.push([index, commodity.bar_price]);
          }
        });
        // Redraw the graph
        plot = $.plot('.graphs', data, options);
      });
      // Do this 1x per second
      setTimeout('update_prices()', 100);
    });
  }
});
