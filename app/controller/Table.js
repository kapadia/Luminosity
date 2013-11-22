'use strict';

angular.module('LuminosityApp')
  .controller('TableCtrl', function ($scope, $compile, $routeParams, AppState, WorkspaceService) {
    
    $scope.columns = WorkspaceService.getNumericalColumns($routeParams.index);
    
    // TODO: Angular constant?
    var maxCharts = 4;
    var naxes = {'histogram': 1, 'scatter2d': 2, 'scatter3d': 3};
    
    $scope.isDisabled = false;
    $scope.nCharts = 0;
    $scope.nChartsPerRow = 2;
    $scope.selectedChart = null;
    
    // Store the values of the selected axes here
    // Initialize storage for chart axes
    $scope.axes = {};
    for (var i = 0; i < maxCharts; i++) {
      $scope.axes[i] = {};
    }
    
    $scope.getNCharts = function() {
      return WorkspaceService.charts.length;
    }
    $scope.getRows = function() {
      var nRows = Math.ceil($scope.nCharts / $scope.nChartsPerRow);
      return new Array(nRows);
    }
    
    $scope.getChartsPerRow = function(index) {
      var index = $scope.nChartsPerRow * index;
      var charts = WorkspaceService.charts.slice(index, index + $scope.nChartsPerRow);
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
    
    // Add chart
    $scope.onChart = function(type) {
      WorkspaceService.charts.push(type);
      $scope.nCharts = WorkspaceService.charts.length;
      $scope.isDisabled = WorkspaceService.charts.length === maxCharts ? true : false;
      
      // // Broadcast added chart to existing charts
      // $scope.$broadcast('chart-added');
    }
    
    $scope.$on('chart-ready', function() {
      $scope.$broadcast('chart-added');
    });
    
    $scope.onChartSpace = function(index) {
      // Change the selected chart
      $scope.selectedChart = index;
      
      // Update with selected axes
      $scope.axis1 = $scope.axes[index].axis1;
      $scope.axis2 = $scope.axes[index].axis2;
      $scope.axis3 = $scope.axes[index].axis3;
    }
    
    
  });