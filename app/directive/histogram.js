'use strict';

angular.module('LuminosityApp')
  .directive('histogram', function (WorkspaceService, HistogramService) {
    return {
      templateUrl: '/views/histogram.html',
      restrict: 'E',
      replace: true,
      link: function postLink(scope, element, attrs) {
        var index = parseInt(attrs.index);
        
        var width = element[0].offsetWidth;
        var height = width * (9 / 16);
        element[0].style.height = height + "px";
        
        var margin = {top: 10, right: 30, bottom: 30, left: 60};
        width = width - margin.left - margin.right;
        height = height - margin.top - margin.bottom;
        
        var x = d3.scale.linear()
            .range([0, width])
        var y = d3.scale.linear()
            .range([height, 0]);
        
        var xAxis = d3.svg.axis()
            .scale(x)
            .orient("bottom");
            
        var yAxis = d3.svg.axis()
            .scale(y)
            .orient("left")
        
        var svg = d3.select(element[0]).append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
        
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
        
        var hasData = false;
        
        // Watch changes to axes values
        scope.$watch('axes.' + index, function() {
          var axis1 = scope.axes[index].axis1;
          if (!axis1)
            return;
          
          // Get data from file
          WorkspaceService.getColumn(scope.axes[index].axis1, function(data) {
            var extent, h, bar;
            
            // Get the min, max and histogram
            // TODO: Bayesian Blocks?
            extent = WorkspaceService.getExtent(data);
            h = HistogramService.compute(data, extent[0], extent[1], 100);
            
            // Set axes domains and transition
            x.domain(extent);
            y.domain([0, d3.max(h)]);
            svg.select(".x").transition().duration(500).call(xAxis);
            svg.select(".y").transition().duration(500).call(yAxis);
            
            if (hasData) {
              bar = svg.selectAll(".bar")
                    .data(h)
                  .transition()
                    .duration(500)
                    .attr("transform", function(d, i) { return "translate(" + x(extent[0] + i * h.dx) + "," + y(d) + ")"; });
              
              bar.select("rect")
                .attr("x", 1)
                .attr("width", x(h.dx) - 1)
                .attr("height", function(d) { return height - y(d); });
            } else {
              bar = svg.selectAll(".bar")
                  .data(h)
                .enter().append("g")
                  .attr("class", "bar")
                  .attr("transform", function(d, i) { return "translate(" + x(extent[0] + i * h.dx) + "," + y(d) + ")"; });
                  
              bar.append("rect")
                  .attr("x", 1)
                  .attr("width", x(h.dx) - 1)
                  .attr("height", function(d) { return height - y(d); });
            }
            
            hasData = true;
          })
        }, true)
      }
    };
  });
