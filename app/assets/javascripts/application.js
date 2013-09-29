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
    $('#container').highcharts({
        title: {
        	text: 'AAPL Historic Data'
        },
        xAxis: {
            categories: ['9/27/13', '9/26/13','9/25/13', '9/24/13', '9/23/13', '9/20/13', '9/19/13', '9/18/13', '9/17/13', '9/16/13', '9/13/13']
        },
        series: [{
            data: [482.75, {y: 486.4, marker: { fillColor: 'red', radius: 6 } }, 481.53, 489.1, 490.64, 467.41, 472.3, 464.68, 455.32, {y: 444.4, marker: { fillColor: 'red', radius: 6 } }, 464.9],
            step: false,
            name: 'AAPL'
        }]

    });
});
