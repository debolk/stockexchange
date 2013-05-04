$(document).ready(function(){

  // Load Google API
  google.load('visualization','1',{'packages': ['corechart'], 'callback':drawChart});

  // Store all state external
  var charts = [];
  var datas = [];
  var options = [];

  // Draw charts initially
  function drawChart()
  {
    // Load commodities
    $.getJSON('/commodities', function(commodities){
      $(commodities).each(function(){
        // Construct a dataTable
        var data = new google.visualization.DataTable();
        data.addColumn('datetime', 'Moment');
        data.addColumn('number', 'Price');

        // Set graph options
        var options = {
          title: this.name,
          legend: {position: 'none'},
          vAxis: {baselineColor: '#fff'},
          hAxis: {baselineColor: '#fff'},
        };

        // Draw chart
        var target = $('<div>').addClass('graph').appendTo('.graphs');
        var chart = new google.visualization.LineChart(target[0]);
        chart.draw(data, options);

        // Store for further reference
        datas[this.id] = data;
        charts[this.id] = chart;
        options[this.id] = options;
      });
      // Update prices in the graph
      update_prices();
    });
  }

  // Regularly update prices of commodities
  window.update_prices = function()
  {
    // Load updated commodities from server
    $.getJSON('/commodities', function(commodities) {
      $(commodities).each(function(){
        // Add a new entry to the dataTable
        datas[this.id].addRow([new Date(), this.bar_price]);
        // Redraw the graph
        charts[this.id].draw(datas[this.id], options[this.id]);
      });
      // Do this 1x per second
      setTimeout('update_prices()', 1000);
    });
  }
});
