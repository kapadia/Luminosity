'use strict';

angular.module('LuminosityApp')
  .controller('ImageCtrl', function ($scope, $routeParams, AppState, WorkspaceService) {
    $scope.index = $routeParams.index;
    
    $scope.stretch = 'linear';
    $scope.minimum = 1;
    $scope.maximum = 1000;
    $scope.stretches = ['linear', 'logarithm', 'sqrt', 'arcsinh', 'power'];
    
    $scope.colormap = 'binary';
    
    var colormaps = Object.keys(rawimage.colormaps);
    var index = colormaps.indexOf('base64');
    colormaps.splice(index, 1);
    
    $scope.colormaps = colormaps;
  });
