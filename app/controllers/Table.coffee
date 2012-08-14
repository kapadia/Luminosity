
class TableController extends Spine.Controller
  
  constructor: ->
    console.log 'Table'
    super
    
    @html require('views/table')(@item.data)
    
    # Create a sortable table
    $("#dataunit-#{@index} .fits-table").tablesorter()
    
    # Store DOM elements
    @axes = $("#dataunit-#{@index} select.axis")
    @plot = $("#dataunit-#{@index} .plot")
    
    # Bind events for plots
    @axes.change (e) =>
      @trigger 'axisChange'
    @bind 'axisChange', @createPlot
  
  createPlot: =>
    console.log 'createPlot'
    [axis1, axis2] = [@axes.first().val(), @axes.last().val()]

    dataunit = @item.data
    dataunit.rowsRead = 0

    data = []
    for column, index in dataunit.columns
      data.push([])

    for row in [1..dataunit.rows]
      for value, index in dataunit.getRow()
        data[index].push value

    # Using D3 to create a scatter plot
    @plot.empty()

    width = 600
    height = 300
    margin = {top: 20, right: 15, bottom: 60, left: 60}

    xdata = data[axis1]
    ydata = data[axis2]

    x = d3.scale.linear().domain([d3.min(xdata), d3.max(xdata)]).range([0, width])
    y = d3.scale.linear().domain([d3.min(ydata), d3.max(ydata)]).range([0, height])

    chart = d3.select("#dataunit-#{@index} .plot")
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


module.exports = TableController