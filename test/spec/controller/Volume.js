'use strict';

describe('Controller: VolumeCtrl', function () {

  // load the controller's module
  beforeEach(module('LuminosityApp'));

  var VolumeCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    VolumeCtrl = $controller('VolumeCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
