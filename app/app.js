(function() {
  'use strict';

  angular.module('LuminosityApp', ['ngRoute'])
    .config(function ($routeProvider, $locationProvider) {
      $locationProvider.html5Mode(true);
      
      $routeProvider
        .when('/', {
          templateUrl: '/views/main.html',
          controller: 'MainCtrl'
        })
        .when('/workspace', {
          templateUrl: '/views/workspace.html',
          controller: 'WorkspaceCtrl'
        })
        .when('/header/:index', {
          templateUrl: '/views/header.html',
          controller: 'HeaderCtrl'
        })
        .when('/image/:index', {
          templateUrl: '/views/image.html',
          controller: 'ImageCtrl'
        })
        .when('/binarytable/:index', {
          templateUrl: '/views/table.html',
          controller: 'TableCtrl'
        })
        .when('/volume/:index', {
          templateUrl: '/views/volume.html',
          controller: 'VolumeCtrl'
        })
        .otherwise({
          redirectTo: '/'
        });
    });
  
  // Prevent default drop behavior across entire DOM
  window.ondragover = function(e) { e.preventDefault(); }
  window.ondrop = function(e) { e.preventDefault(); }
})()
