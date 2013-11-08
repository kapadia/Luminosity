'use strict';

describe('Controller: WorkspaceCtrl', function () {

  // load the controller's module
  beforeEach(module('LuminosityApp'));

  var WorkspaceCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    WorkspaceCtrl = $controller('WorkspaceCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
