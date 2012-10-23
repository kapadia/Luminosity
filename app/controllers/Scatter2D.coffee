
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
    
    axis1 = []
    axis2 = []
    index1 = @axis1.val()
    index2 = @axis2.val()
    
    console.log index1, index2
    dataunit = @hdu.data
    rows = dataunit.rows
    for i in [1..rows]
      row = dataunit.getRow(i - 1)
      axis1.push(row[index1])
      axis2.push(row[index2])
    
    margin =
      top: 20
      right: 20
      bottom: 60
      left: 50
      
    width = @el.innerWidth() - margin.left - margin.right - parseInt(@el.css('padding-left')) - parseInt(@el.css('padding-right'))
    height = @el.innerHeight() - margin.top - margin.bottom - parseInt(@el.css('padding-top')) - parseInt(@el.css('padding-bottom'))
    
    x = d3.scale.linear()
      .range([0, width])
      .domain(d3.extent(axis1))
    y = d3.scale.linear()
      .range([0, height])
      .domain(d3.extent(axis2))
    
    xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")
    yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")
      
    svg = d3.select("#hdu-#{@index} .scatter-2d .graph").append('svg')
            .attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)
          .append('g')
            .attr('transform', "translate(#{margin.left}, #{margin.top})")     
    svg.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + height + ")")
          .call(xAxis)
    svg.append("g")
          .attr("class", "y axis")
          .call(yAxis)
          
    svg.selectAll(".dot")
        .data(axis2)
      .enter().append("circle")
        .attr("class", "dot")
        .attr("r", 1.5)
        .attr("cx", (d, i) -> return x(axis1[i]))
        .attr("cy", (d, i) -> return y(axis2[i]))

module.exports = Scatter2D