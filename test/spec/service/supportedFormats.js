'use strict';

describe('Service: supportedFormats', function () {

  // load the service's module
  beforeEach(module('LuminosityApp'));

  // instantiate service
  var supportedFormats;
  beforeEach(inject(function (_supportedFormats_) {
    supportedFormats = _supportedFormats_;
  }));

  it('should do something', function () {
    expect(!!supportedFormats).toBe(true);
  });

});
