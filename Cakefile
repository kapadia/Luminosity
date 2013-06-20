{print} = require 'util'
{spawn} = require 'child_process'
{exec} = require 'child_process'

watch = require('watch')
path = require('path')

task 'build', 'Build from server/', ->
  coffee = spawn 'node_modules/.bin/coffee', ['-c', '-m', '-o', '.', 'server']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

task 'server', 'Watch for changes', ->
  
  watch.createMonitor('.', (monitor) ->
    
    monitor.on("changed", (f, cur, prev) ->
      ext = path.extname(f)
      if ext in ['.coffee', '.styl']
        exec('hem build', ->
          console.log 'Build complete'
        )
    )
  )
  
  coffee = spawn 'node_modules/.bin/coffee', ['-w', '-c', '-m', '-o', '.', 'server']
  nodemon = spawn 'node_modules/.bin/nodemon', ['server.js']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  nodemon.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  nodemon.stdout.on 'data', (data) ->
    print data.toString()