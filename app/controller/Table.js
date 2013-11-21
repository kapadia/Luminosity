'use strict';

angular.module('LuminosityApp')
  .controller('TableCtrl', function ($scope, $compile, $routeParams, AppState, WorkspaceService) {
    
    $scope.columns = WorkspaceService.getNumericalColumns($routeParams.index);
    
    // TODO: Angular constant?
    var nChartsPerRow = 2;
    var maxCharts = 4;
    var naxes = {'histogram': 1, 'scatter2d': 2, 'scatter3d': 3};
    
    $scope.isDisabled = false;
    $scope.nCharts = 0;
    $scope.selectedChart = null;
    
    // Store the values of the selected axes here
    // Initialize storage for chart axes
    $scope.axes = [];
    for (var i = 0; i < maxCharts; i++) {
      $scope.axes[i] = {};
    }
    
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
    
    $scope.onAxis = function() {
      var chartIndex = $scope.selectedChart;
      var chartType = WorkspaceService.charts[chartIndex];
      
      var axes = naxes[chartType];
      for (var i = 1; i < axes + 1; i++) {
        var key = 'axis' + i;
        $scope.axes[chartIndex][key] = $scope[key];
      }
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
