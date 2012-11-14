Graph = require('controllers/Graph')

class Histogram extends Graph
  name: 'Histogram'
  axes: 1
  
  events:
    "change .histogram select[data-axis='1']" : 'draw'
    "click .histogram button[name='save']"    : 'savePlot'
  
  draw: =>
    index1 = @axis1.val()
    
    if index1 is '-1'
      @saveButton.prop('disabled', true)
      return null
    @saveButton.prop('disabled', false)
    
    @plot.empty()
    
    # Get label for the axis
    @key1 = xlabel = @axis1.find("option:selected").text()
    
    # Trigger event with column names
    @trigger 'onColumnChange', xlabel
    
    # Get units if they are available
    header = @hdu.header
    unit1Key = "TUNIT#{parseInt(index1) + 1}"
    xlabel += " (#{header[unit1Key]})" if header.contains(unit1Key)
    
    @data = []
    
    dataunit = @hdu.data
    rows = dataunit.rows
    for i in [1..rows]
      row = dataunit.getRow(i - 1)
      @data.push row[@key1]
    
    numBins = parseInt(@data.length / 10)
    bins = d3.layout.histogram().bins(numBins)(@data)
    firstBin = bins[0]
    lastBin = bins[bins.length-1]
    ymax = d3.max(bins, (d) -> d.y)
    
    margin =
      top: 20
      right: 20
      bottom: 60
      left: 50
    
    width = @el.width() - margin.left - margin.right - parseInt(@el.css('padding-left')) - parseInt(@el.css('padding-right'))
    height = @el.height() - margin.top - margin.bottom - parseInt(@el.css('padding-top')) - parseInt(@el.css('padding-bottom'))
    
    @x = d3.scale.linear()
      .range([0, width])
      .domain([firstBin.x, lastBin.x])
      
    @y = d3.scale.linear()
      .range([height, 0])
      .domain([0, ymax])
      
    @xAxis = d3.svg.axis()
      .scale(@x)
      .ticks(6)
      .orient("bottom")
    @yAxis = d3.svg.axis()
      .scale(@y)
      .orient("left")
      .ticks(6)
    
    @svg = d3.select("#dataunit#{@index} .histogram .graph").append('svg')
            .attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)
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
    
    @bars = @svg.selectAll('.bar')
              .data(bins)
            .enter().append('rect')
              .attr('class', 'bar')
              .attr('x', (d) => return @x(d.x))
              .attr('width', width / numBins)
              .attr('y', (d) => return @y(d.y))
              .attr('height', (d) => return height - @y(d.y))
    
    @svg.append('g')
      .attr('class', 'brush')
      .attr('width', width)
      .attr('height', height)
      .call(d3.svg.brush().x(@x)
      .on('brushstart', @brushstart)
      .on('brush', @brushmove)
      .on('brushend', @brushend))
      .selectAll('rect')
      .attr('height', height)

  brushstart: =>
    @svg.classed("selecting", true)

  brushmove: =>
    e = d3.event.target.extent()
    @bars.classed 'selected', (d) =>
      return e[0][0] <= d[@key1] and d[@key1] <= d[1][0]

  brushend: =>
    data = {}
    data[@key1] = d3.event.target.extent()
    @trigger 'brushend', data
    @svg.classed('selecting', !d3.event.target.empty())

module.exports = Histogram