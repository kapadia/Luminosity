'use strict';

angular.module('LuminosityApp')
  .directive('scatter3d', function () {
    return {
      templateUrl: '/views/scatter3d.html',
      restrict: 'E',
      replace: true,
      controller: function($scope, WorkspaceService) {
        $scope.onAxis = function() {
          if ($scope.axis1 && $scope.axis2 && $scope.axis3)
            WorkspaceService.getThreeColumns($scope.axis1, $scope.axis2, $scope.axis3, $scope.chart);
        }
      },
      link: function postLink(scope, element, attrs) {
        var chartEl = element[0].querySelector('div.ruse');
        scope.chart = new ruse(chartEl, 480, 300);
      }
    };
  });
