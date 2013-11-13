'use strict';

angular.module('LuminosityApp')
  .controller('TableCtrl', function ($scope, $routeParams, AppState, WorkspaceService) {
    
    $scope.columns = WorkspaceService.getNumericalColumns($routeParams.index);
    console.log($scope.columns);
    
    $scope.getNCharts = function() {
      return WorkspaceService.nCharts;
    }
    
    $scope.getCharts = function() {
      return WorkspaceService.charts;
    }
    
    $scope.onHistogram = function() {
      WorkspaceService.charts.push('histogram');
    }
    $scope.onScatter2D = function() {
      WorkspaceService.charts.push('scatter2d');
    }
    $scope.onScatter3D = function() {
      WorkspaceService.charts.push('scatter3d');
    }
    
    
  });
