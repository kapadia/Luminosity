'use strict';

angular.module('LuminosityApp')
  .directive('histogram', function () {
    return {
      templateUrl: '/views/histogram.html',
      restrict: 'E',
      replace: true,
      transclude: false,
      controller: function($scope, WorkspaceService) {
        
        $scope.onAxis = function() {
          console.log($scope);
          
          // Get column data from file
          WorkspaceService.getColumn($scope.axis, $scope.chart);
        }
      },
      link: function postLink(scope, element, attrs) {
        console.log('linking histogram directive');
        var chartEl = element[0].querySelector('div.ruse');
        console.log(chartEl);
        scope.chart = new ruse(chartEl, 480, 300);
      }
    };
  });
