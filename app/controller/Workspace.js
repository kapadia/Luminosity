'use strict';

angular.module('LuminosityApp')
  .controller('WorkspaceCtrl', function ($scope, $location, AppState, WorkspaceService) {
    console.log('WorkspaceCtrl');
    
    //  TODO: Not secure right now. Could implement another cycle to server
    //        and place template behind authenticated endpoint.
    if (!AppState.isAuthenticated)
      $location.path('/');
    
    // TODO: Move to application state?
    $scope.isHeaderSelected = false;
    $scope.isBintableSelected = false;
    
    // TODO: Figure out ng-change events
    var xAxis = document.querySelector("#x-axis");
    var yAxis = document.querySelector("#y-axis");
    var zAxis = document.querySelector("#z-axis");
    
    function onAxis() {
      // Get all axis values
      var xValue = xAxis.value;
      var yValue = yAxis.value;
      var zValue = zAxis.value;
      
      if (xValue && yValue && zValue) {
        console.log(xValue, yValue, zValue);
      }
    }
    xAxis.onchange = onAxis;
    yAxis.onchange = onAxis;
    zAxis.onchange = onAxis;
    
    $scope.getHeaders = function() {
      return WorkspaceService.getHeaders();
    }
    
    $scope.onHeader = function(index) {
      $scope.isHeaderSelected = true;
      $scope.cards = WorkspaceService.file.hdus[index].header.cards;
    }
    
    $scope.onCloseHeader = function() {
      $scope.isHeaderSelected = false;
      $scope.cards = null;
    }
    
    $scope.onCloseBinTable = function() {
      $scope.isBintableSelected = false;
      $scope.columns = null;
    }
    
    $scope.onDataUnit = function(index) {
      $scope.columns = WorkspaceService.getColumnsFromDataUnit(index);
      $scope.isBintableSelected = true;
    }
    
    $scope.onAxis = function(value, index) {
      console.log(value, index);
    }
    
  });
