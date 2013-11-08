'use strict';

describe('Directive: workspace', function () {

  // load the directive's module
  beforeEach(module('LuminosityApp'));

  var element,
    scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  it('should make hidden element visible', inject(function ($compile) {
    element = angular.element('<workspace></workspace>');
    element = $compile(element)(scope);
    expect(element.text()).toBe('this is the workspace directive');
  }));
});
