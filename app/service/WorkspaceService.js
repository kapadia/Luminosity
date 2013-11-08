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
      $rootScope.$apply();  // Re-render scope
    }
    
    workspace.getHeaders = function() {
      if (workspace.file === undefined)
        return null;
      return workspace.file.hdus.map(function(hdu) { return hdu.header.getDataType(); });
    }
    
    workspace.getColumnsFromDataUnit = function(index) {
      var dataunit = workspace.file.getDataUnit(index);
      return dataunit.columns;
    }
    
    return workspace;
  });
