'use strict';

angular.module('LuminosityApp')
  .controller('TableCtrl', function ($scope, $compile, $routeParams, AppState, WorkspaceService) {
    
    $scope.columns = WorkspaceService.getNumericalColumns($routeParams.index);
    $scope.naxes = {'histogram': [1], 'scatter2d': [1, 2], 'scatter3d': [1, 2, 3]};
    
    // TODO: Angular constant?
    var nChartsPerRow = 2;
    var maxCharts = 4;
    
    $scope.isDisabled = false;
    $scope.nCharts = 0;
    $scope.selectedChart = null;
    
    $scope.getNCharts = function() {
      return WorkspaceService.charts.length;
    }
    $scope.getRows = function() {
      var nRows = Math.ceil($scope.nCharts / nChartsPerRow);
      return new Array(nRows);
    }
    
    $scope.getChartsPerRow = function(index) {
      var index = nChartsPerRow * index;
      var charts = WorkspaceService.charts.slice(index, index + nChartsPerRow);
      return charts;
    }
    
    $scope.getAxes = function(chartType) {
      return $scope.naxes[chartType];
    }
    
    $scope.onAxis = function(index) {
      console.log('onAxis', index);
    }
    
    $scope.onChart = function(type) {
      WorkspaceService.charts.push(type);
      $scope.nCharts = WorkspaceService.charts.length;
      $scope.isDisabled = WorkspaceService.charts.length === maxCharts ? true : false;
    }
    
    $scope.onChartSpace = function(index) {
      $scope.selectedChart = index;
    }
    
    
  });
