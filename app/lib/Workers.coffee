# This module is used to provide inline workers to this application

# Inline workers are used as an alternative to separate JavaScript files which must be included
# separately from the main JavaScript application.  By using inline workers we can include all JS in one
# file.

Workers =
  createWorker: (script) =>
    
    blob = new Blob([script], {type: "text/plain;charset=UTF-8"})
    url = Workers.createObjectURL(blob)
    worker = new Worker(url)
    worker.addEventListener 'message', ((e) =>
    ), false
    worker.postMessage()
  
  createObjectURL: => return window.webkitURL.createObjectURL or window.URL.createObjectURL