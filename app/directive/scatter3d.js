'use strict';

angular.module('LuminosityApp')
  .directive('scatter3d', function () {
    return {
      template: '<div></div>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        element.text('this is the scatter3d directive');
      }
    };
  });
