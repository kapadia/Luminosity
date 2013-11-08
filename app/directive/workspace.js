'use strict';

angular.module('LuminosityApp')
  .directive('workspace', function (WorkspaceService) {
    return {
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        
        // Attach drag and drop handlers
        window.ondragover = function(e) { e.preventDefault(); }
        window.ondrop = function(e) {
          e.preventDefault();
          
          // Limit to a single file for now
          var fileList = e.dataTransfer.files;
          if (fileList.length != 1)
            return
          
          // Pass to service for heavy lifting
          WorkspaceService.onFile(fileList[0]);
        }
        
      }
    };
  });
