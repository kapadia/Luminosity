'use strict';

angular.module('LuminosityApp')
  .directive('scatter2d', function () {
    return {
      template: '<div></div>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        element.text('this is the scatter2d directive');
      }
    };
  });
