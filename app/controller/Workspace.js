'use strict';

angular.module('LuminosityApp')
  .controller('WorkspaceCtrl', function ($scope, $location, AppState, WorkspaceService) {
    console.log('WorkspaceCtrl');
    
    //  TODO: Not secure right now. Could implement another cycle to server
    //        and place template behind authenticated endpoint.
    if (!AppState.isAuthenticated)
      $location.path('/');
    
    // Recover state
    if (WorkspaceService.file) {
      var index = WorkspaceService.selectedHeader;
      $scope.cards = WorkspaceService.file.hdus[index].header.cards;
    }
    
    // Listen for when file is ready and default header to primary HDU
    $scope.$on('file-ready', function() {
      WorkspaceService.selectedHeader = 0;
      $scope.cards = WorkspaceService.file.hdus[0].header.cards;
    })
    
    $scope.getHeaders = function() {
      return WorkspaceService.getHeaders();
    }
    
    $scope.onHeader = function(index) {
      WorkspaceService.selectedHeader = index;
      $scope.cards = WorkspaceService.file.hdus[index].header.cards;
    }
    
    $scope.onDataUnit = function(index, dataunit) {
      // TODO: Call appropriate function depending on the dataunit
      console.log(dataunit);
      $scope.columns = WorkspaceService.getColumnsFromDataUnit(index);
      $scope.isBintableSelected = true;
    }
    
  });
