'use strict';

describe('Directive: scatter2d', function () {

  // load the directive's module
  beforeEach(module('LuminosityApp'));

  var element,
    scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  it('should make hidden element visible', inject(function ($compile) {
    element = angular.element('<scatter2d></scatter2d>');
    element = $compile(element)(scope);
    expect(element.text()).toBe('this is the scatter2d directive');
  }));
});
