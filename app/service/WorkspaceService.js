'use strict';

angular.module('LuminosityApp')
  .service('WorkspaceService', function WorkspaceService($rootScope, supportedFormats) {
    
    // Utility functions
    // TODO: abstract to another service if too many utilities defined
    function getExtension(filename) {
      var split = filename.split('.');
      var extension = split[split.length - 1];
      return extension;
    }
    
    // This singleton is used for doing the heavy lifting in the workspace
    var workspace = {};
    
    // Set default parameters
    // TODO: This service encompasses entire file state. Might want to abstract this later.
    workspace.selectedHeader = 0;
    workspace.charts = [];
    
    workspace.onFile = function(f) {
      
      // Check file extension
      var extension = getExtension(f.name);
      if (supportedFormats.indexOf(extension) === -1) {
        alert("File format " + extension + " is not supported.");
        return;
      }
      
      // Pass to appropriate file parser
      // TODO: Support more than just FITS (e.g. csv, other sci formats)
      new astro.FITS(f, workspace.onFITS);
    }
    
    // Callback for when FITS is parsed
    // TODO: Create handlers for other file formats
    workspace.onFITS = function(fits) {
      workspace.file = fits;
      $rootScope.$broadcast("file-ready");
      $rootScope.$apply();  // Re-render scope
    }
    
    workspace.getHeaders = function() {
      if (workspace.file === undefined)
        return null;
      return workspace.file.hdus.map(function(hdu) { return hdu.header.getDataType(); });
    }
    
    //
    // Table specific functions
    //
    
    workspace.getNumericalColumns = function(index) {
      var table = workspace.file.getDataUnit(index);
      var header = workspace.file.getHeader(index);
      
      var columns = table.columns;
      var regex = /(\d*)([BIJKED])/;
      var numericalColumns = [];
      
      for (var i = 1; i < columns.length + 1; i++) {
        var form = "TFORM" + i;
        var type = "TTYPE" + i;
        var match = header.get(form).match(regex);
        if (typeof match !== "undefined" && match !== null)
          numericalColumns.push( header.get(type) );
      }
      
      return numericalColumns;
    }
    
    workspace.getColumnsFromDataUnit = function(index) {
      var dataunit = workspace.file.getDataUnit(index);
      workspace.index = index;
      return dataunit.columns;
    }
    
    workspace.getColumn = function(axis, fn) {
      var dataunit = workspace.file.getDataUnit(workspace.index);
      console.log(axis);
      
      dataunit.getColumn(axis, function(data) {
        fn.call(fn, data);
      });
    }
    
    // TODO: Implement efficient getColumns methods in fitsjs
    workspace.getTwoColumns = function(axis1, axis2, fn) {
      var dataunit = workspace.file.getDataUnit(workspace.index);
      
      dataunit.getColumn(axis1, function(xData) {
        dataunit.getColumn(axis2, function(yData) {
          var data = [];
          for (var i = 0; i < xData.length; i++) {
            var obj = {};
            obj[axis1] = xData[i];
            obj[axis2] = yData[i];
            
            data.push(obj);
          }
          fn.call(fn, data);
        });
      });
    }
    
    workspace.getThreeColumns = function(axis1, axis2, axis3, chart) {
      var dataunit = workspace.file.getDataUnit(workspace.index);
      
      dataunit.getColumn(axis1, function(xData) {
        dataunit.getColumn(axis2, function(yData) {
          dataunit.getColumn(axis3, function(zData) {
            var data = [];
            for (var i = 0; i < xData.length; i++) {
              var obj = {};
              obj[axis1] = xData[i];
              obj[axis2] = yData[i];
              obj[axis3] = zData[i];

              data.push(obj);
            }
            chart.plot(data);
          });
        });
      });
    }
    
    workspace.getExtent = function(arr) {
      var index, max, min, value;
      
      index = arr.length;
      while (index--) {
        value = arr[index];
        if (isNaN(value)) {
          continue;
        }
        min = max = value;
        break;
      }
      if (index === -1) {
        return [NaN, NaN];
      }
      while (index--) {
        value = arr[index];
        if (isNaN(value)) {
          continue;
        }
        if (value < min) {
          min = value;
        }
        if (value > max) {
          max = value;
        }
      }
      return [min, max];
    }
    
    return workspace;
  });
