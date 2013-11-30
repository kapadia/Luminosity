'use strict';

angular.module('LuminosityApp')
  .directive('rawimage', function (WorkspaceService, $timeout) {
    return {
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        
        var width, height;
        
        var viewerEl = element[0].querySelector('.viewer');
        var controlEl = element[0].querySelector('.control');
        
        width = viewerEl.offsetWidth;
        viewerEl.style.height = width + 'px';
        controlEl.style.height = width + 'px';
        
        var rawView = new astro.WebFITS(viewerEl, width);
        rawView.setupControls();
        WorkspaceService.getImage(scope.index, function(arr, width, height, min, max) {
          rawView.loadImage('img', arr, width, height);
          rawView.setExtent(min, max);
          rawView.setStretch('linear');
        });
        
      }
    };
  });
