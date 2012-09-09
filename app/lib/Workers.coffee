# Code to generate inline web workers

# TODO: Variables should be shortened manually.  Any JS compressor won't minify this.
Workers =
  
  Image: [
    "importScripts('http://0.0.0.0:9294/lib/fits.js');",
    
    "self.addEventListener('message', (function (e) {",
      "var msg, data, f, hdu, header, dataunit, width, height;",
      "var FITS = require('fits');"
      "data = e.data;",
      
      "f = new FITS.File(data.buffer);",
      "hdu = f.getHDU(data.index);",
      "header = hdu.header;",
      "dataunit = hdu.data;",
      
      "dataunit.data = new Float32Array(header['NAXIS1'] * header['NAXIS2']);",
      "dataunit.getFrame();",
      "dataunit.getExtremes();",
      
      "msg = {",
        "data: dataunit.data,",
        "min: dataunit.min,",
        "max: dataunit.max,",
        "frame: dataunit.frame",
      "};",
      "self.postMessage(msg);",
    "}), false);"
  ].join("\n")
  
  Histogram: [
    "var computeHistogram;",

    "computeHistogram = function(min, max, bins, data) {",
      "var arrayType, binSize, diff, flotHistogram, histogram, index, mean, numpixels, pixel, range, std, step, sum, values, _i, _j, _len, _len1;",
      "range = max - min;",
      "binSize = range / bins;",
      "numpixels = data.length;",
      "if (numpixels < 256) {",
        "arrayType = Uint8Array;",
      "} else if (numpixels < 65535) {",
        "arrayType = Uint16Array;",
      "} else {",
        "arrayType = Uint32Array;",
      "}",
      "sum = 0;",
      "histogram = new arrayType(bins + 1);",
      "flotHistogram = new Array(bins + 1);",
      "for (_i = 0, _len = data.length; _i < _len; _i++) {",
        "pixel = data[_i];",
        "sum += pixel;",
        "index = Math.floor(((pixel - min) / range) * bins);",
        "histogram[index] += 1;",
        "step = min + binSize * index;",
        "flotHistogram[index] = [step, histogram[index]];",
      "}",
      "mean = sum / numpixels;",
      "sum = 0;",
      "for (_j = 0, _len1 = flotHistogram.length; _j < _len1; _j++) {",
        "values = flotHistogram[_j];",
        "if (values == null) {",
          "continue;",
        "}",
        "diff = values[0] - mean;",
        "sum += (diff * diff) * values[1];",
      "}",
      "std = Math.sqrt(sum / numpixels);",
      "return [flotHistogram, mean, std];",
    "};",
    
    "self.addEventListener('message', (function (e) {",
      "var data, msg;",
      "data = e.data;",
      "var stats;",

      "stats = computeHistogram(data.min, data.max, data.bins, data.data);",
      
      "msg = {histogram: stats[0], mean: stats[1], std: stats[2], band: data.band};",
      "self.postMessage(msg);",
    "}), false);"
  ].join("\n")

module?.exports = Workers