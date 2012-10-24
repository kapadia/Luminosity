
class Scatter2D extends Spine.Controller
  name: 'Scatter 2D'
  
  events:
    'change .scatter-2d select[data-axis=1]' : 'draw'
    'change .scatter-2d select[data-axis=2]' : 'draw'
    
  constructor: ->
    super
    console.log 'Scatter2D'
    
    @render()
    @plot   = $("#hdu-#{@index} .scatter-2d .graph")
    @axis1  = $("#hdu-#{@index} .scatter-2d select[data-axis=1]")
    @axis2  = $("#hdu-#{@index} .scatter-2d select[data-axis=2]")
    
  render: ->
    attrs = {columns: @columns, name: @name, axes: 2}
    @html require('views/plot')(attrs)
    
  draw: =>
    console.log 'draw'
    @plot.empty()
    
    @xdata = []
    @ydata = []
    index1 = @axis1.val()
    index2 = @axis2.val()
    
    dataunit = @hdu.data
    rows = dataunit.rows
    for i in [1..rows]
      row = dataunit.getRow(i - 1)
      @xdata.push(row[index1])
      @ydata.push(row[index2])
    
    margin =
      top: 20
      right: 20
      bottom: 60
      left: 50
      
    width = @el.innerWidth() - margin.left - margin.right - parseInt(@el.css('padding-left')) - parseInt(@el.css('padding-right'))
    height = @el.innerHeight() - margin.top - margin.bottom - parseInt(@el.css('padding-top')) - parseInt(@el.css('padding-bottom'))
    
    @x = d3.scale.linear()
      .range([0, width])
      .domain(d3.extent(@xdata))
    @y = d3.scale.linear()
      .range([height, 0])
      .domain(d3.extent(@ydata))
    
    @xAxis = d3.svg.axis()
      .scale(@x)
      .orient("bottom")
    @yAxis = d3.svg.axis()
      .scale(@y)
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
    @svg.append("g")
          .attr("class", "y axis")
          .call(@yAxis)
          
    @svg.selectAll(".dot")
        .data(@ydata)
      .enter().append("circle")
        .attr("class", "dot")
        .attr("r", 1.5)
        .attr("cx", (d, i) => return @x(@xdata[i]))
        .attr("cy", (d, i) => return @y(@ydata[i]))
  
  zoom: =>
    @svg.select(".x.axis").call(@xAxis)
    @svg.select(".y.axis").call(@yAxis)
    @svg.selectAll(".dot")
      .attr("cx", (d, i) => return @x(@xdata[i]))
      .attr("cy", (d, i) => return @y(@ydata[i]))
    
module.exports = Scatter2D