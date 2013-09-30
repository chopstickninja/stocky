// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require_tree .

$(document).foundation();

 $(function () {
    $("#addStrategy").click(function(event) {
        event.preventDefault();
        var user_id = parseInt($(event.currentTarget).attr("data-id"));
        var query = "this is the query";
        var callback = "this is the callback";
        var startDate = "06/10/13"
        $.ajax({
            url: "/strategies/",
            type: "POST",
            data: {"strategy": {"user_id" : user_id, "query" : query, "callback" : callback, "start_date" : startDate } },
            success: function(response){
                $("#addStrategy").attr('disabled','disabled');
                $("#addStrategy").text("Added!");
        }
      });
    });
    
    $("#executeStrategy").click(function(event){
      event.preventDefault();
      $.ajax({
          url: "/algo_positions/",
          type: "GET",
          success: function(response){
            buildChart();
            var json_data = response;
            $('#container').removeAttr("hidden");
             $('#datatable').removeAttr("hidden");
            var tablestring = "";
            for(var i=0; i < json_data.length; i++){
              tablestring +='<tr>'
              tablestring += '<td>' + json_data[i].date + '</td>'
              tablestring += '<td>' + json_data[i].price + '</td>'
              tablestring += '<td>' + json_data[i].buyorsell + '</td>'
              tablestring+= '</tr>'
            }
            
            $('#tableBody').html(tablestring);
            }
      });
    });
    
    var buildChart = function(){
      $.ajax({
        url: "/hist_prices/",
        type: "GET",
        success: function(response){
          var points = response;
          var leng = parseInt(points.length/12)
          var dates = [];
          var prices = [];
          var i = 0;
          while (i < points.length){
            dates.push(points[i].date);
            prices.push(points[i].price);
            i += leng
          }
          // for(var i =0; i < points.length; i++){
          //   dates.push(points[i].date);
          //   prices.push(points[i].price);
          // }
          prices[0] = {y: prices[0], marker: { fillColor: 'red', radius: 6 } }
          prices[prices.length - 1] = {y: prices[prices.length - 1], marker: { fillColor: 'red', radius: 6 } }
          $('#container').highcharts({
              title: {
              	text: 'YHOO Historic Data'
              },
              xAxis: {
                  categories: dates
              },
              series: [{
                  data: prices,
                  step: false,
              }]

          });
        }
      });
    };

});
