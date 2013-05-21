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
      
      // Store commodities for usage by the ticker
      window.commodities = commodities;

      // Add new prices to the graph
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

  /*
   * Ticker tape
   */
  // Store current price

  // Average price used by the ticker
  window.commodities = [];
  window.ticker_average_price = 0;

  // Determines the direction of the ticker
  window.ticker_direction = function() {
    // No commodities retrieved yet? Return default
    if (window.commodities.length == 0) {
      return 0;
    }

    // Calculate new ticker price
    var total_price = 0;
    for (var i = 0; i < window.commodities.length; i++) {
      total_price += parseInt(commodities.bar_price);
    }
    var new_average_price = total_price / commodities.length;

    // Compare to old price to determine direction
    var direction = null;
    var minimum_change_needed = 20;
    if (Math.abs(new_average_price - ticker_average_price) < minimum_change_needed) {
      direction = 0;
    }
    else if (new_average_price > ticker_average_price) {
      direction = +1;
    }
    else if (new_average_price < ticker_average_price) {
      direction = -1;
    }

    // Store new price for later usage
    window.ticker_average_price = new_average_price

    // Return direction of graph
    return direction;
  }

  // Show graph
  // Direction is either -1 (lower prices) or 1 (higher prices)
  window.showTicker = function(){
    var ticker = $('#ticker');
    var message_index = Math.floor(Math.random()*ticker_texts.length);
    var direction = ticker_direction();
    // Determine message and color
    if (direction == 0) {
      ticker.css('background-color', 'darkorange');
      ticker.text(ticker_texts[2][message_index]);
    }
    else if (direction == -1) {
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
    setTimeout(showTicker, 30000);
  }

  window.ticker_texts = [[
    'Olieton zakt door level: prijzen dalen',
    'Lokaal alcoholoverschot in Delft',
    'Nieuw proces voor het efficiënter uitpersen van limoenen',
    'Noodweer maakt investeren in paraplu\'s noodzakelijk: alcoholconsumptie daalt',
    'Olieprijs daalt: transportkosten nemen af',
  ],[
    'Olieton ontploft: prijs gaat door het dak',
    'Overheid investeert extra in studiefinanciëring',
    'Treinen rijden niet: lokale consumptie van alcohol stijgt',
    'Tentamens afgerond: consumptie van drank stijgt extreem',
    'Paardenvlees gevonden in biertank: afname cocktails stijgt',
    'Kameel ontsnapt: transportkosten stijgen',
    'Regenachtige dag: oliesjeiks volkomen ontregeld',
  ],[
    'Niets te melden',
    'Meer vrouwen gespot in Delft: geen enkel effect op lokale nerds merkbaar in statistieken',
    'Liedje over Anne B. stijgt naar plek 2 in de Hitparade',
    'Vrede op aarde: werkeloosheid onder journalisten stijgt',
    'Nieuw station "Delft De Bolk" blijkt onvoldoende populair',
  ]];

  showTicker(0);
});
