'use strict';

describe('Service: AppState', function () {

  // load the service's module
  beforeEach(module('LuminosityApp'));

  // instantiate service
  var AppState;
  beforeEach(inject(function (_AppState_) {
    AppState = _AppState_;
  }));

  it('should do something', function () {
    expect(!!AppState).toBe(true);
  });

});
