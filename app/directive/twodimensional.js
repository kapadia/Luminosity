'use strict';

angular.module('LuminosityApp')
  .directive('twodimensional', function (WorkspaceService, $timeout) {
    return {
      templateUrl: '/views/twodimensional.html',
      restrict: 'E',
      replace: true,
      link: function postLink(scope, element, attrs) {
        
        var hasData, aspectRatio, initialRadius, margin, x, y, xAxis, yAxis, color,
            svg, chartGroup, axesGroup, plotGroup, xAxisGroup, yAxisGroup, width,
            height, xExtent, yExtent, index, axis1, axis2, chartData, zoom, xt, yt, scale;
        
        index = parseInt(attrs.index);
        hasData = false;
        
        // Angular constant?
        aspectRatio = 9 / 16;
        initialRadius = 6;
        
        // Set margin for D3 chart
        margin = {top: 10, right: 30, bottom: 20, left: 40};
        
        // Create axes
        x = d3.scale.linear();
        y = d3.scale.linear();
        xAxis = d3.svg.axis().orient('bottom');
        yAxis = d3.svg.axis().orient('left');
        
        // Create colormap
        color = d3.scale.linear()
            .domain([0, 50])
            .range(["white", "steelblue"])
            .interpolate(d3.interpolateLab);
        
        // Create SVG element and groups
        svg = d3.select(element[0]).append('svg');
        
        // One group for clip path and chart
        chartGroup = svg.append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');
        
        // Another group for axes
        axesGroup = svg.append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');
        
        chartGroup.append('clipPath')
            .attr('id', 'clip' + index)
          .append('rect')
            .attr('class', 'mesh');
        plotGroup = chartGroup.append('g')
              .attr('clip-path', 'url(#clip' + index + ')')
              .attr("transform", "translate(0, 0)")
            .append('g')
              .attr("class", "chart");
        
        xAxisGroup = axesGroup.append('g').attr('class', 'x axis');
        yAxisGroup = axesGroup.append('g').attr('class', 'y axis');
        
        function createHexbin(radius) {
          return d3.hexbin()
              .size([width, height])
              .radius(radius)
              .x(function(d) { return (x(d[axis1]) - xt) / scale; })
              .y(function(d) { return (y(d[axis2]) - yt) / scale; });
        }
        
        function createPlot(data, hexbin) {
          plotGroup.selectAll('.hexagon').remove();
          plotGroup.selectAll('.dot').remove();
          
          // Determine chart type from data length
          // NOTE: Length threshold should be parameter (angular constant?)
          if (data.length > 8000) {
            plotGroup.selectAll('.hexagon')
                .data(hexbin(data))
              .enter().append('path')
                .attr('class', 'hexagon')
                .attr('d', hexbin.hexagon())
                .attr('transform', function(d) { return 'translate(' + d.x + ',' + d.y + ')'; })
                .style('fill', function(d) { return color(d.length); });
          } else {
            plotGroup.selectAll('.dot')
                .data(data)
              .enter().append('circle')
              .attr('class', 'dot')
              .attr('r', 0.1)
              .attr('cx', function(d) { return (x(d[axis1]) - xt) / scale; })
              .attr('cy', function(d) { return (y(d[axis2]) - yt) / scale; });
          }
        }
        
        function onzoom() {
          xAxisGroup.call(xAxis);
          yAxisGroup.call(yAxis);
          plotGroup.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
        }
        
        function onzoomend() {
          var radius, xmin, xmax, ymin, ymax, filteredData, hexbin;
          
          scale = zoom.scale();
          radius = initialRadius / scale;
          xt = zoom.translate()[0], yt = zoom.translate()[1];
          
          xmin = x.domain()[0], xmax = x.domain()[1];
          ymin = y.domain()[0], ymax = y.domain()[1];
          function isInBounds(obj) {
            var x, y;
            x = obj[axis1], y = obj[axis2];
            return (x > xmin && x < xmax && y > ymin && y < ymax);
          }
          filteredData = chartData.filter(isInBounds);
          
          hexbin = createHexbin(radius);
          createPlot(filteredData, hexbin);
        }
        
        // Listen for when chart element is ready
        scope.$on('chart-added', function() {
          $timeout(function() {
            
            // Reset default values
            xt = yt = 0;
            scale = 1;
            
            // Get width and compute height based on the aspect ratio
            width = element[0].offsetWidth;
            height = width * aspectRatio;
            element[0].style.height = height + 'px';
            
            // Get new width and height accounting for margins
            width = width - margin.left - margin.right;
            height = height - margin.top - margin.bottom;
            
            // Update range of axes 
            x.range([0, width]);
            y.range([height, 0]);
            xAxis.scale(x);
            yAxis.scale(y);
            
            // Update SVG attributes
            svg
              .attr("width", width + margin.left + margin.right)
              .attr("height", height + margin.top + margin.bottom);
            
            // Select is okay on non-frequently used DOM elements
            svg.select('.mesh')
              .attr('width', width)
              .attr('height', height);
            
            xAxisGroup.attr('transform', 'translate(0,' + height + ')').call(xAxis);
            yAxisGroup.call(yAxis);
            
            // Redraw chart when another chart is added to layout
            // TODO: This resets the chart. Need to preserve the state.
            if (hasData) {
              x.domain(xExtent);
              y.domain(yExtent);
              xAxisGroup.transition().duration(500).call(xAxis);
              yAxisGroup.transition().duration(500).call(yAxis);
              
              plotGroup.attr("transform", "translate(0, 0)");
              zoom
                .x(x)
                .y(y);
              
              var radius = initialRadius / scale;
              var hexbin = createHexbin(radius);
              createPlot(chartData, hexbin);
            }
            
          }, 0);
        });
        
        // Watch for axes selection represented by model change on scope
        scope.$watch('axes.' + index, function() {
          var hexbin;
          
          // Check if axes are selected
          axis1 = scope.axes[index].axis1;
          axis2 = scope.axes[index].axis2;
          if (!axis1 || !axis2)
            return;
          
          WorkspaceService.getTwoColumns(axis1, axis2, function(data) {
            
            // Get minimum and maximum
            xExtent = d3.extent(data, function(d) { return d[axis1]; });
            yExtent = d3.extent(data, function(d) { return d[axis2]; });
            
            // Update domains of axes
            x.domain(xExtent);
            y.domain(yExtent);
            
            xAxis.scale(x);
            yAxis.scale(y);
            
            xAxisGroup.transition().duration(500).call(xAxis);
            yAxisGroup.transition().duration(500).call(yAxis);
            
            // Make data accessible to other functions
            chartData = data;
            
            hexbin = createHexbin(initialRadius);
            createPlot(chartData, hexbin);
            
            // Create zoom behaviour and attach to SVG
            zoom = d3.behavior.zoom()
                .x(x)
                .y(y)
                .scaleExtent([1, 16])
                .on("zoom", onzoom)
                .on("zoomend", onzoomend);
            svg.call(zoom);
            
            hasData = true;
          });
        }, true);
        
        // Broadcast that chart element is ready
        scope.$emit('chart-ready');
        
        // Clean up event handlers
        scope.$on('$destroy', function() {});
        
      }
      
    };
  });
