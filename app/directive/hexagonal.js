'use strict';

angular.module('LuminosityApp')
  .directive('hexagonal', function (WorkspaceService, $timeout) {
    return {
      templateUrl: '/views/hexagonal.html',
      restrict: 'E',
      replace: true,
      link: function postLink(scope, element, attrs) {
        var aspectRatio, margin, x, y, xAxis, yAxis, 
            svg, color, hexbin, chartGroup, axesGroup, xAxisEl, yAxisEl,
            width, height, index, hasData, xExtent, yExtent,
            clipPathEl, groupEl, chartData, zoom, scale, initialRadius, radius,
            axis1, axis2;
        
        hasData = false;
        
        // Angular constant?
        aspectRatio = 9 / 16;
        initialRadius = 8;
        
        // Set margin for D3 chart
        margin = {top: 10, right: 30, bottom: 20, left: 40};
        
        // Create axes
        x = d3.scale.linear();
        y = d3.scale.linear();
        xAxis = d3.svg.axis().orient('bottom');
        yAxis = d3.svg.axis().orient('left');
        
        // Create colormap
        color = d3.scale.linear()
            .domain([0, 40])
            .range(["white", "steelblue"])
            .interpolate(d3.interpolateLab);
        
        // Create SVG element and groups
        svg = d3.select(element[0]).append('svg');
        
        // One group for all plotted points and clip path
        chartGroup = svg.append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');
        
        // Another group for axes
        // Using two group helps when performing transforms during zoom and pan.
        axesGroup = svg.append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');
        
        // TODO: Create unique id
        chartGroup.append('clipPath')
            .attr('id', 'clip')
          .append('rect')
            .attr('class', 'mesh');
        var plotGroup = chartGroup.append('g')
              .attr("clip-path", "url(#clip)")
              .attr("transform", "translate(0, 0)")
            .append('g')
              .attr("class", "chart");
        
        xAxisEl = axesGroup.append('g').attr('class', 'x axis');
        yAxisEl = axesGroup.append('g').attr('class', 'y axis');
        
        function onzoom() {
          xAxisEl.call(xAxis);
          yAxisEl.call(yAxis);
          plotGroup.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
        }
        
        function onzoomend() {
          var xt, yt;
          
          scale = zoom.scale();
          radius = initialRadius / scale;
          xt = zoom.translate()[0];
          yt = zoom.translate()[1];
          
          var xmin = x.domain()[0];
          var xmax = x.domain()[1];
          var ymin = y.domain()[0];
          var ymax = y.domain()[1];
          function isInBounds(obj) {
            var x = obj[axis1];
            var y = obj[axis2];
            return (x > xmin && x < xmax && y > ymin && y < ymax);
          }
          var filtered = chartData.filter(isInBounds);
          hexbin = d3.hexbin()
              .size([width, height])
              .radius(radius)
              .x(function(d) { return (x(d[axis1]) - xt) / scale; })
              .y(function(d) { return (y(d[axis2]) - yt) / scale; });
          
          plotGroup.selectAll(".hexagon").remove();
          plotGroup.selectAll(".hexagon")
              .data(hexbin(filtered))
            .enter().append("path")
              .attr("class", "hexagon")
              .attr("d", hexbin.hexagon())
              .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
              .style("fill", function(d) { return color(d.length); });
        }
        
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
            
            // Select is okay on non-frequently used DOM elements
            svg.select('.mesh')
              .attr('width', width)
              .attr('height', height);
            
            xAxisEl.attr('transform', 'translate(0,' + height + ')').call(xAxis);
            yAxisEl.call(yAxis);
            
            if (hasData) {
              x.domain(xExtent);
              y.domain(yExtent);
              xAxisEl.transition().duration(500).call(xAxis);
              yAxisEl.transition().duration(500).call(yAxis);
              
              // Remove previous hexagons
              groupEl.selectAll('.hexagon').remove();
              
              groupEl.selectAll('.hexagon')
                  .data(hexbin(chartData))
                .enter().append("path")
                  .attr('class', 'hexagon')
                  .attr('d', hexbin.hexagon())
                  .attr('transform', function(d) { return "translate(" + d.x + "," + d.y + ")"; })
                  .style("fill", function(d) { return color(d.length); });
            }
            
          }, 0);
        });
        
        // Watch for model change on scope
        index = parseInt(attrs.index);
        scope.$watch('axes.' + index, function() {
          
          axis1 = scope.axes[index].axis1;
          axis2 = scope.axes[index].axis2;
          if (!axis1 || !axis2)
            return;
          
          WorkspaceService.getTwoColumns(axis1, axis2, function(data) {
            
            // Get min and max
            xExtent = d3.extent(data, function(d) { return d[axis1]; });
            yExtent = d3.extent(data, function(d) { return d[axis2]; });
            
            // Set axes domains and transition
            x.domain(xExtent).range([0, width]);
            y.domain(yExtent).range([height, 0]);
            
            xAxis.scale(x);
            yAxis.scale(y);
            
            xAxisEl.transition().duration(500).call(xAxis);
            yAxisEl.transition().duration(500).call(yAxis);
            
            // Create hexbin object with accessor functions
            hexbin = d3.hexbin()
                      .size([width, height])
                      .radius(initialRadius)
                      .x(function(d) { return x(d[axis1]); })
                      .y(function(d) { return y(d[axis2]); });
            
            // Make data accessible to other functions
            chartData = data;
            
            // Remove previous hexagons
            plotGroup.selectAll('.hexagon').remove();
            
            // Create plot points
            plotGroup.selectAll('.hexagon')
                .data(hexbin(chartData))
              .enter().append("path")
                .attr('class', 'hexagon')
                .attr('d', hexbin.hexagon())
                .attr('transform', function(d) { return "translate(" + d.x + "," + d.y + ")"; })
                .style("fill", function(d) { return color(d.length); });
            
            zoom = d3.behavior.zoom()
                .x(x)
                .y(y)
                .scaleExtent([1, 8])
                .on("zoom", onzoom)
                .on("zoomend", onzoomend);
            
            svg.call(zoom);
            
            hasData = true;
          });
        }, true);
        
        // Broadcast that chart element is ready
        scope.$emit('chart-ready');
        
        // Clean up event handlers
        scope.$on('$destroy', function() {
          
        });
      }
      
    };
  });
