(function() {
  'use strict';

  angular.module('LuminosityApp', ['ngRoute', 'ngCookies'])
    .config(function ($routeProvider, $locationProvider) {
      $locationProvider.html5Mode(true);

      $routeProvider
        .when('/', {
          templateUrl: 'views/main.html',
          controller: 'MainCtrl'
        })
        .when('/workspace', {
          templateUrl: 'views/workspace.html',
          controller: 'WorkspaceCtrl'
        })
        .otherwise({
          redirectTo: '/'
        });
    });
  
  // Prevent default drop behavior across entire DOM
  window.ondragover = function(e) { e.preventDefault(); }
  window.ondrop = function(e) { e.preventDefault(); }
  // window.addEventListener("dragover", function(e) { e.preventDefault(); }, false);
  // window.addEventListener("drop", function(e) { e.preventDefault(); }, false);
})()
