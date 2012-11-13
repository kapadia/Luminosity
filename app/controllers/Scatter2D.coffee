Graph = require('controllers/Graph')

class Scatter2D extends Graph
  name: 'Scatter 2D'
  axes: 2
  formatter: d3.format(".3f")
  
  events:
    "change .scatter-2d select[data-axis='1']"  : 'draw'
    "change .scatter-2d select[data-axis='2']"  : 'draw'
    "click .scatter-2d button[name='save']"     : 'savePlot'
  
  draw: =>
    index1 = @axis1.val()
    index2 = @axis2.val()
    
    if index1 is '-1' or index2 is '-1'
      @saveButton.prop('disabled', true)
      return null
    @saveButton.prop('disabled', false)
    
    @plot.empty()
    
    # Get labels for the axes
    @key1 = xlabel = @axis1.find("option:selected").text()
    @key2 = ylabel = @axis2.find("option:selected").text()
    
    # Trigger event with column names
    @trigger 'onColumnChange', xlabel, ylabel
    
    # Get units if they are available
    header = @hdu.header
    unit1Key = "TUNIT#{parseInt(index1) + 1}"
    unit2Key = "TUNIT#{parseInt(index2) + 1}"
    xlabel += " (#{header[unit1Key]})" if header.contains(unit1Key)
    ylabel += " (#{header[unit2Key]})" if header.contains(unit2Key)
    
    @data = []
    
    dataunit = @hdu.data
    
    # TODO: This is an expensive operation.  Ship off to worker, or find way
    #       to do it asynchronously.
    rows = dataunit.rows
    for i in [1..rows]
      row = dataunit.getRow(i - 1)
      datum = {}
      datum[@key1] = row[@key1]
      datum[@key2] = row[@key2]
      @data.push datum
    
    margin =
      top: 20
      right: 20
      bottom: 60
      left: 50
      
    width = @el.width() - margin.left - margin.right - parseInt(@el.css('padding-left')) - parseInt(@el.css('padding-right'))
    height = @el.height() - margin.top - margin.bottom - parseInt(@el.css('padding-top')) - parseInt(@el.css('padding-bottom'))
    
    @x = d3.scale.linear()
      .range([0, width])
      .domain(d3.extent(@data, (d) => return d[@key1]))
    @y = d3.scale.linear()
      .range([height, 0])
      .domain(d3.extent(@data, (d) => return d[@key2]))
    
    @xAxis = d3.svg.axis()
      .scale(@x)
      .ticks(6)
      .orient("bottom")
    @yAxis = d3.svg.axis()
      .scale(@y)
      .ticks(6)
      .orient("left")
    
    @svg = d3.select("#hdu-#{@index} .scatter-2d .graph").append('svg')
            .attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)
            .call(d3.behavior.zoom().x(@x).y(@y).scaleExtent([1, 8]).on("zoom", @zoom))
          .append('g')
            .attr('transform', "translate(#{margin.left}, #{margin.top})")
    @svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(@xAxis)
      .append("text")
        .attr("class", "label")
        .attr("x", width)
        .attr("y", -6)
        .style("text-anchor", "end")
        .text(xlabel)
    @svg.append("g")
        .attr("class", "y axis")
        .call(@yAxis)
      .append("text")
        .attr("class", "label")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text(ylabel)
    
    @svg.append('g')
      .attr('class', 'brush')
      .call(d3.svg.brush().x(@x).y(@y)
      .on('brushstart', @brushstart)
      .on('brush', @brushmove)
      .on('brushend', @brushend))
    
    @circles = @svg.append('g').selectAll('circle')
        .data(@data)
      .enter().append('circle')
        .attr('class', 'dot')
        .attr('r', 1.5)
        .attr('cx', (d) => return @x(d[@key1]))
        .attr('cy', (d) => return @y(d[@key2]))
        .on('mouseover', @showInfo)
        .on('mouseout', @hideInfo)
  
  showInfo: (d, i) =>
    item = d3.select(@svg.selectAll(".dot")[0][i])
    item.attr("r", 4)
    item.style("fill", d3.rgb(255, 0, 0))
    @info.html("(#{@formatter(d[@key1])}, #{@formatter(d[@key2])})")
    @info.css({
      'top': d3.event.pageY - 25,
      'left': d3.event.pageX - 100
    })
    @info.show()
  
  hideInfo: (d, i) =>
    item = d3.select(@svg.selectAll(".dot")[0][i])
    item.attr("r", 1.5)
    item.style("fill", d3.rgb(0, 0, 0))
    $("#info").hide()
  
  zoom: =>
    super
    @svg.selectAll(".dot")
      .attr("cx", (d) => return @x(d[@key1]))
      .attr("cy", (d) => return @y(d[@key2]))
  
  brushstart: =>
    @svg.classed("selecting", true)
    
  brushmove: =>
    e = d3.event.target.extent()
    @circles.classed 'selected', (d) =>
      return e[0][0] <= d[@key1] and d[@key1] <= e[1][0] and e[0][1] <= d[@key2] and d[@key2] <= e[1][1]
    
  brushend: =>
    d = d3.event.target.extent()
    data = {}
    data[@key1] = d.map( (x) -> return x[0])
    data[@key2] = d.map( (x) -> return x[1])
    @trigger 'brushend', data
    @svg.classed('selecting', !d3.event.target.empty())
  
module.exports = Scatter2D
