'use strict';

describe('Controller: TableCtrl', function () {

  // load the controller's module
  beforeEach(module('LuminosityApp'));

  var TableCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    TableCtrl = $controller('TableCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
