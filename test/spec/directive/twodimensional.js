'use strict';

describe('Directive: twodimensional', function () {

  // load the directive's module
  beforeEach(module('LuminosityApp'));

  var element,
    scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  it('should make hidden element visible', inject(function ($compile) {
    element = angular.element('<twodimensional></twodimensional>');
    element = $compile(element)(scope);
    expect(element.text()).toBe('this is the twodimensional directive');
  }));
});
