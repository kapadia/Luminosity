'use strict';

angular.module('LuminosityApp')
  .service('AppState', function AppState() {
    var state = {},
        bodyEl;
    
    bodyEl = document.querySelector('body');
    state.isAuthenticated = false;
    
    state.setWorkspace = function() {
      bodyEl.addEventListener('dragover', onDragOver, false);
      bodyEl.addEventListener('drop', onDrop, false);
    }
    state.unsetWorkspace = function() {
      bodyEl.removeEventListener('dragover', onDragOver, false);
      bodyEl.removeEventListener('drop', onDrop, false);
    }
    
    
    return state;
  });