FITS  = require('fits')
ImageController = require('controllers/Image')

class Handler extends Spine.Controller
  elements:
    '#header-tabs' : 'tabs'
  
  constructor: ->
    super
    
  readBuffer: (buffer) ->
    @fits = new FITS.File(buffer)
    @renderTabs()
    @readData()
  
  renderTabs: ->
    hdus = @fits.hdus
    @html require('views/viewer')(hdus)
    
    # Store the current tab when selected
    options =
      select: (e, ui) =>
        @currentTab = ui.index
    @tabs.tabs(options)
    @currentTab = 0   # Default to the first tab
    
    # Keyboard shortcuts for tabs
    window.addEventListener('keypress', @shortcuts, false)
  
  shortcuts: (e) =>
    numTabs = @tabs.tabs('length')
    keyCode = e.keyCode
    if keyCode in [49..57]
      index = keyCode - 49
      @tabs.tabs('select', index)
  
  readData: =>
    for hdu, index in @fits.hdus
      header  = hdu.header
      data    = hdu.data
      
      elem = $("#dataunit-#{index}")
      # Check for image
      if header.isPrimary() and header.hasDataUnit()
        
        # Initialize new Image controller
        new ImageController({el: elem, item: hdu, index: @currentTab})
      
      # Handle other extension  
      else if header.isExtension()
        if header['XTENSION'] is 'TABLE'
          # Render the tabular data to screen
          $("#dataunit-#{index}").append require('views/table')(data)
          $("#hdu-#{index}").append("<div class='plot'></div>")
          
          # Create a sortable table
          $('.fits-table').tablesorter()
          
          # Bind events for plots
          @axes = $("select.axis")
          @axes.change (e) =>
            @trigger 'axisChange'
          @bind 'axisChange', @createPlot
  
  setupWebGLUI: ->
    console.log 'setupWebGLUI'
    
    
    
  createPlot: =>
    console.log 'createPlot'
    [axis1, axis2] = [@axes.first().val(), @axes.last().val()]
    
    dataunit = @fits.getHDU(@currentTab).data
    dataunit.rowsRead = 0
    
    data = []
    for column, index in dataunit.columns
      data.push([])
    
    for row in [1..dataunit.rows]
      for value, index in dataunit.getRow()
        data[index].push value
    
    # Using D3 to create a scatter plot
    $(".plot").empty()
    
    width = 600
    height = 300
    margin = {top: 20, right: 15, bottom: 60, left: 60}
    
    xdata = data[axis1]
    ydata = data[axis2]
    
    x = d3.scale.linear().domain([d3.min(xdata), d3.max(xdata)]).range([0, width])
    y = d3.scale.linear().domain([d3.min(ydata), d3.max(ydata)]).range([0, height])
    
    chart = d3.select('.plot')
      .append('svg:svg')
      .attr('width', width + margin.right + margin.left)
      .attr('height', height + margin.top + margin.bottom)
      .attr('class', 'chart')
    
    main = chart.append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
      .attr('width', width)
      .attr('height', height)
      .attr('class', 'main')
    
    xAxis = d3.svg.axis()
      .scale(x)
      .orient('bottom')

    main.append('g')
      .attr('transform', 'translate(0,' + height + ')')
      .attr('class', 'main axis date')
      .call(xAxis)
    
    yAxis = d3.svg.axis()
      .scale(y)
      .orient('left')

    main.append('g')
      .attr('transform', 'translate(0,0)')
      .attr('class', 'main axis date')
      .call(yAxis)

    g = main.append("svg:g")

    g.selectAll("scatter-dots")
      .data(ydata)
      .enter().append("svg:circle")
        .attr("cy", (d) ->
          return y(d)
        )
        .attr("cx", (d, i) ->
          return x(xdata[i])
        )
        .attr("r", 1)
        .style("opacity", 0.6)
        .style("stroke", "#CD3E20")
        
        
module.exports = Handler