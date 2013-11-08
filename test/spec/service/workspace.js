'use strict';

describe('Service: workspace', function () {

  // load the service's module
  beforeEach(module('LuminosityApp'));

  // instantiate service
  var workspace;
  beforeEach(inject(function (_workspace_) {
    workspace = _workspace_;
  }));

  it('should do something', function () {
    expect(!!workspace).toBe(true);
  });

});
