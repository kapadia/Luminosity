'use strict';

angular.module('LuminosityApp')
  .directive('histogram', function () {
    return {
      templateUrl: '/views/histogram.html',
      restrict: 'E',
      replace: true,
      controller: function($scope, WorkspaceService) {
        $scope.onAxis = function() {
          WorkspaceService.getColumn($scope.axis, $scope.chart);
        }
      },
      link: function postLink(scope, element, attrs) {
        var chartEl = element[0].querySelector('div.ruse');
        scope.chart = new ruse(chartEl, 480, 300);
      }
    };
  });
