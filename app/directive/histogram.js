'use strict';

angular.module('LuminosityApp')
  .directive('histogram', function (WorkspaceService, HistogramService, $timeout) {
    return {
      templateUrl: '/views/histogram.html',
      restrict: 'E',
      replace: true,
      link: function postLink(scope, element, attrs) {
        var aspectRatio, margin, x, y, xAxis, yAxis, svg, chartEl, xAxisEl, yAxisEl, width, height, index, hasData;
        
        hasData = false;
        
        // Angular constant?
        aspectRatio = 9 / 16;
        
        // Set margin for D3 chart
        margin = {top: 10, right: 30, bottom: 20, left: 40};
        
        // Create axes
        x = d3.scale.linear();
        y = d3.scale.linear();
        xAxis = d3.svg.axis().orient('bottom');
        yAxis = d3.svg.axis().orient('left');
        
        // Create SVG elements
        svg = d3.select(element[0]).append('svg');
        chartEl = svg.append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');
        xAxisEl = chartEl.append('g').attr('class', 'x axis');
        yAxisEl = chartEl.append('g').attr('class', 'y axis');
        
        // Listen for when chart element is ready
        scope.$on('chart-added', function() {
          $timeout(function() {
            
            // Get width and compute height
            width = element[0].offsetWidth;
            height = width * aspectRatio;
            element[0].style.height = height + 'px';
            
            // Get new width and height
            width = width - margin.left - margin.right;
            height = height - margin.top - margin.bottom;
            
            // Update axes
            x.range([0, width]);
            y.range([height, 0]);
            xAxis.scale(x);
            yAxis.scale(y);
            
            // Update SVG attributes
            svg
              .attr("width", width + margin.left + margin.right)
              .attr("height", height + margin.top + margin.bottom);
            
            chartEl.attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');
            xAxisEl.attr('transform', 'translate(0,' + height + ')').call(xAxis);
            
          }, 0);
        });
        
        // Watch for model change on scope
        index = parseInt(attrs.index);
        scope.$watch('axes.' + index, function() {
          var axis1 = scope.axes[index].axis1;
          if (!axis1)
            return;
          
          // Get data from file
          WorkspaceService.getColumn(axis1, function(data) {
            var extent, hist, bar;
            
            // Get the min, max and histogram
            // TODO: Bayesian Blocks?
            extent = WorkspaceService.getExtent(data);
            hist = HistogramService.compute(data, extent[0], extent[1], 100);
            
            // Set axes domains and transition
            x.domain(extent);
            y.domain([0, d3.max(hist)]);
            xAxisEl.transition().duration(500).call(xAxis);
            yAxisEl.transition().duration(500).call(yAxis);
            
            if (hasData) {
              bar = chartEl.selectAll(".bar")
                    .data(hist)
                  .transition()
                    .duration(500)
                    .attr("transform", function(d, i) { return "translate(" + x(extent[0] + i * hist.dx) + "," + y(d) + ")"; });
                    
              bar.select("rect")
                .attr("x", 1)
                .attr("width", x(hist.dx) - 1)
                .attr("height", function(d) { return height - y(d); });
            } else {
              bar = chartEl.selectAll(".bar")
                  .data(hist)
                .enter().append("g")
                  .attr("class", "bar")
                  .attr("transform", function(d, i) { return "translate(" + x(extent[0] + i * hist.dx) + "," + y(d) + ")"; });
                
              bar.append("rect")
                  .attr("x", 1)
                  .attr("width", x(hist.dx) - 1)
                  .attr("height", function(d) { return height - y(d); });
            }
            hasData = true;
            
          });
        }, true);
        
        // Broadcast that chart element is ready
        scope.$emit('chart-ready');
        // svg.append("g")
        //     .attr("class", "y axis")
        //     .call(yAxis)
        //   .append("text")
        //     .attr("transform", "rotate(-90)")
        //     .attr("y", 6)
        //     .attr("dy", ".71em")
        //     .style("text-anchor", "end")
        //     .text("Count");
        // 
        // var hasData = false;
        // 
        // // Watch changes to axes values
        // scope.$watch('axes.' + index, function() {
        //   var axis1 = scope.axes[index].axis1;
        //   if (!axis1)
        //     return;
        //   
        //   // Get data from file
        //   WorkspaceService.getColumn(scope.axes[index].axis1, function(data) {
        //     var extent, h, bar;
        //     
        //     // Get the min, max and histogram
        //     // TODO: Bayesian Blocks?
        //     extent = WorkspaceService.getExtent(data);
        //     h = HistogramService.compute(data, extent[0], extent[1], 100);
        //     
        //     // Set axes domains and transition
        //     x.domain(extent);
        //     y.domain([0, d3.max(h)]);
        //     svg.select(".x").transition().duration(500).call(xAxis);
        //     svg.select(".y").transition().duration(500).call(yAxis);
        //     
        //     if (hasData) {
        //       bar = svg.selectAll(".bar")
        //             .data(h)
        //           .transition()
        //             .duration(500)
        //             .attr("transform", function(d, i) { return "translate(" + x(extent[0] + i * h.dx) + "," + y(d) + ")"; });
        //       
        //       bar.select("rect")
        //         .attr("x", 1)
        //         .attr("width", x(h.dx) - 1)
        //         .attr("height", function(d) { return height - y(d); });
        //     } else {
        //       bar = svg.selectAll(".bar")
        //           .data(h)
        //         .enter().append("g")
        //           .attr("class", "bar")
        //           .attr("transform", function(d, i) { return "translate(" + x(extent[0] + i * h.dx) + "," + y(d) + ")"; });
        //           
        //       bar.append("rect")
        //           .attr("x", 1)
        //           .attr("width", x(h.dx) - 1)
        //           .attr("height", function(d) { return height - y(d); });
        //     }
        //     
        //     hasData = true;
        //   })
        // }, true)
        // 
        // // Listen for layout changes (e.g. chart added)
        // scope.$on('chart-added', function() {
        //   var width, height;
        //   
        //   // With a new chart, the layout has changes and the parent div has new dimensions
        //   width = element[0].offsetWidth;
        //   console.log('new width', width, element[0]);
        //   
        // });
        
      }
    };
  });
