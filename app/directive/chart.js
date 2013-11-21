'use strict';

angular.module('LuminosityApp')
  .directive('chart', function () {
    return {
      template: '<div></div>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        element.text('this is the chart directive');
      }
    };
  });
