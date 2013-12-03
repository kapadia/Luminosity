'use strict';

angular.module('LuminosityApp')
  .directive('rawimage', function (WorkspaceService, $timeout) {
    return {
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        
        var width, height, minimum, maximum, gMinimum, gRange;
        
        var viewerEl = element[0].querySelector('.viewer');
        var controlEl = element[0].querySelector('.control');
        
        width = viewerEl.offsetWidth;
        viewerEl.style.height = width + 'px';
        controlEl.style.height = width + 'px';
        
        var rawView = new rawimage(viewerEl, width);
        rawView.setupControls();
        WorkspaceService.getImage(scope.index, function(arr, width, height, min, max) {
          gMinimum = min, gRange = max - min;
          minimum = min, maximum = max;
          
          // Downsample image when larger than the maximum texture size
          if (width > rawView.gl.getParameter(rawView.gl.MAX_TEXTURE_SIZE)) {
            var downsampled = rawView.downsample(arr, width, height, 4);
            rawView.loadImage('img', downsampled.arr, downsampled.width, downsampled.height);
            console.log(downsampled.width, downsampled.height);
          } else {
            rawView.loadImage('img', arr, width, height);  
          }
          rawView.setExtent(min, max);
          rawView.setStretch('linear');
        });
        
        
        scope.$watch('stretch', function() {
          rawView.setStretch(scope.stretch);
        });
        scope.$watch('colormap', function() {
          console.log(scope.colormap);
          rawView.setColorMap(scope.colormap);
        });
        
        function mapRange(x) { return (gRange / 1000) * x + gMinimum; }
        scope.$watch('minimum', function() {
          minimum = mapRange(scope.minimum);
          rawView.setExtent(minimum, maximum);
        });
        scope.$watch('maximum', function() {
          maximum = mapRange(scope.maximum);
          rawView.setExtent(minimum, maximum);
        });
      }
    };
  });
