'use strict';

//
// Mozilla Persona for authentication
//

angular.module('LuminosityApp')
  .controller('HeaderCtrl', function ($scope, $http, $location, AppState) {
    
    // Check if online
    if (window.navigator.onLine) {
      navigator.id.watch({
        onlogin: function(assertion) {
          $http.post('/persona/verify', {assertion: assertion})
            .success(function(data) {
              if (data && data.status === 'okay') {
                AppState.isAuthenticated = true;
                $location.path('/workspace');
              }
            })
            .error(function(data) {
              AppState.isAuthenticated = false;
            })
        },
        onlogout: function() {
          $http.post('/persona/logout')
            .success(function() {
              AppState.isAuthenticated = false;
              $location.path('/');
            })
            .error(function() {
              AppState.isAuthenticated = false;
              $location.path('/');
            })
        }
      });

      $scope.onSignIn = function() {
        navigator.id.request();
      }

      $scope.onSignOut = function() {
        navigator.id.logout();
      }
    } else {
      // TODO: Find secure way to check for authentication when offline.
      //       Check cookie for session?
      AppState.isAuthenticated = true;
      $location.path('/workspace');
    }
    
    $scope.isAuthenticated = function() {
      return AppState.isAuthenticated;
    }
    
  });
