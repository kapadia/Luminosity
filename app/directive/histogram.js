'use strict';

angular.module('LuminosityApp')
  .directive('histogram', function (WorkspaceService) {
    return {
      templateUrl: '/views/histogram.html',
      restrict: 'E',
      replace: true,
      // controller: function($scope, WorkspaceService) {
      //   $scope.onAxis = function() {
      //     WorkspaceService.getColumn($scope.axis, $scope.chart);
      //   }
      // },
      link: function postLink(scope, element, attrs) {
        var width = element[0].offsetWidth;
        var height = width * (9 / 16);
        element[0].style.height = height + "px";
        
        var margin = {top: 10, right: 10, bottom: 10, left: 10};
        width = width - margin.left - margin.right;
        height = height - margin.top - margin.bottom;
        
        var x = d3.scale.ordinal()
            .rangeRoundBands([0, width], 0.1);
        var y = d3.scale.linear()
            .range([height, 0]);
        
        var xAxis = d3.svg.axis()
            .scale(x)
            .orient("bottom");
            
        var yAxis = d3.svg.axis()
            .scale(y)
            .orient("left")
            .ticks(10, "%");
        
        var svg = d3.select(element[0]).append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
        
        // TODO: Set domains after reading data
        
        svg.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis);
        
        svg.append("g")
            .attr("class", "y axis")
            .call(yAxis)
          .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", 6)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text("Count");
        
        // scope.onAxis = function() {
        //   console.log('onAxis from directive');
        //   // WorkspaceService.getColumn($scope.axis, $scope.chart);
        // }
        
        // svg.selectAll(".bar")
        //   .data(data)
        // .enter().append("rect")
        //   .attr("class", "bar")
        //   .attr("x", function(d) { return x(d.letter); })
        //   .attr("width", x.rangeBand())
        //   .attr("y", function(d) { return y(d.frequency); })
        //   .attr("height", function(d) { return height - y(d.frequency); });
      }
    };
  });
