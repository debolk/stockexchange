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
    window.commodities = commodities;
    $(commodities).each(function(){
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
      window.commodities = commodities;
      $(commodities).each(function(){
        // Add a new entry to the data
        var commodity = this;
        $(data).each(function(){
          if (this.label == commodity.name) {
            // Drop an entry if the data-set gets too long
            if (this.data.length > 1000) {
              this.data = this.data.slice(1);
            } 
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

  /*
   * Ticker tape
   */
  // Store current price

  // Determines the average price index
  window.ticker_direction = function() {
    if (Math.random() >= 0.5) {
      return 1;
    }
    else {
      return -1;
    }
  }

  // Show graph
  // Direction is either -1 (lower prices) or 1 (higher prices)
  window.showTicker = function(){
    var ticker = $('#ticker');
    var message_index = Math.floor(Math.random()*ticker_texts.length);
    var direction = ticker_direction();
    // Determine message and color
    if (direction == -1) {
      ticker.css('background-color', 'green');
      ticker.text(ticker_texts[0][message_index]);
    }
    else {
      ticker.css('background-color', 'red');
      ticker.text(ticker_texts[1][message_index]);
    }
    ticker.slideDown(1000);
    // Hide the ticker after five seconds
    setTimeout(hideTicker, 5000);
  }
  // Hides the ticker
  window.hideTicker = function() {
    $('#ticker').slideUp(1000);
    setTimeout(showTicker, 5000);
  }

  window.ticker_texts = [[
    'Olieton zakt door level; prijzen dalen',
    'Message 1.0',
    'Message 1.1',
    'Message 1.2',
  ],[
    'Olieton ontploft - prijs gaat door het dak',
    'Message 2.0',
    'Message 2.1',
    'Message 2.2',
    'Message 2.3',
  ]];

  showTicker(+1);
});
