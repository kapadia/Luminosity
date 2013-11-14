'use strict';

angular.module('LuminosityApp')
  .controller('TableCtrl', function ($scope, $compile, $routeParams, AppState, WorkspaceService) {
    
    $scope.columns = WorkspaceService.getNumericalColumns($routeParams.index);
    $scope.naxes = {'histogram': [1], 'scatter2d': [1, 2], 'scatter3d': [1, 2, 3]};
    
    $scope.getNCharts = function() {
      return WorkspaceService.nCharts;
    }
    
    $scope.getCharts = function() {
      return WorkspaceService.charts;
    }
    
    $scope.getAxes = function(chartType) {
      return $scope.naxes[chartType];
    }
    
    $scope.onAxis = function(index) {
      console.log('onAxis', index);
    }
    
    $scope.onHistogram = function() {
      WorkspaceService.charts.push('histogram');
      $compile();
    }
    $scope.onScatter2D = function() {
      WorkspaceService.charts.push('scatter2d');
    }
    $scope.onScatter3D = function() {
      WorkspaceService.charts.push('scatter3d');
    }
    
    
  });
