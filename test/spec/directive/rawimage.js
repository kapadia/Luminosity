'use strict';

describe('Directive: rawimage', function () {

  // load the directive's module
  beforeEach(module('LuminosityApp'));

  var element,
    scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  it('should make hidden element visible', inject(function ($compile) {
    element = angular.element('<rawimage></rawimage>');
    element = $compile(element)(scope);
    expect(element.text()).toBe('this is the rawimage directive');
  }));
});
