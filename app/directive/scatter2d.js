'use strict';

angular.module('LuminosityApp')
  .directive('scatter2d', function (WorkspaceService, $timeout) {
    return {
      templateUrl: '/views/scatter2d.html',
      restrict: 'E',
      replace: true,
      link: function postLink(scope, element, attrs) {
        var aspectRatio, margin, x, y, xAxis, yAxis, svg, chartEl, xAxisEl, yAxisEl, width, height, index, hasData, xExtent, yExtent;
        
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
            
            if (hasData) {
              x.domain(xExtent);
              y.domain(yExtent);
              xAxisEl.transition().duration(500).call(xAxis);
              yAxisEl.transition().duration(500).call(yAxis);
            }
            
          }, 0);
        });
        
        // Watch for model change on scope
        index = parseInt(attrs.index);
        scope.$watch('axes.' + index, function() {
          var axis1, axis2;
          
          axis1 = scope.axes[index].axis1;
          axis2 = scope.axes[index].axis2;
          if (!axis1 || !axis2)
            return;
          
          WorkspaceService.getTwoColumns(axis1, axis2, function(data) {
            
            // Get min and max
            xExtent = d3.extent(data, function(d) { return d[axis1]; });
            yExtent = d3.extent(data, function(d) { return d[axis2]; });
            
            // Set axes domains and transition
            x.domain(xExtent);
            y.domain(yExtent);
            xAxisEl.transition().duration(500).call(xAxis);
            yAxisEl.transition().duration(500).call(yAxis);
            
            if (hasData) {
              chartEl.selectAll('.dot')
                  .data(data)
                .transition()
                  .duration(500)
                  .attr('cx', function(d) { return x(d[axis1]) })
                  .attr('cy', function(d) { return y(d[axis2]) });
            } else {
              chartEl.selectAll('.dot')
                  .data(data)
                .enter().append('circle')
                .attr('class', 'dot')
                .attr('r', 1.5)
                .attr('cx', function(d) { return x(d[axis1]) })
                .attr('cy', function(d) { return y(d[axis2]) });
            }
            hasData = true;
            
          });
        }, true);
        
        // Broadcast that chart element is ready
        scope.$emit('chart-ready');
      }
    };
  });
