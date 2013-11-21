'use strict';

angular.module('LuminosityApp')
  .service('HistogramService', function HistogramService() {
    
    var histogram = {};
    
    histogram.compute = function(arr, min, max, bins) {
      var dx, h, i, index, range, value;
      
      range = max - min;
      h = new Uint32Array(bins);
      dx = range / bins;
      i = arr.length;
      while (i--) {
        value = arr[i];
        index = ~~((value - min) / dx);
        h[index] += 1;
      }
      h.dx = dx;
      
      return h;
    }
    
    return histogram;
  });
