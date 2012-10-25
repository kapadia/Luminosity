
class Scatter2D extends Spine.Controller
  name: 'Scatter 2D'
  formatter: d3.format(".3f")
  
  events:
    'change .scatter-2d select[data-axis=1]'  : 'draw'
    'change .scatter-2d select[data-axis=2]'  : 'draw'
    'click .scatter-2d button[name=save]'     : 'savePlot'
    
  constructor: ->
    super
    console.log 'Scatter2D'
    
    @render()
    @info   = $('#info')
    @plot   = $("#hdu-#{@index} .scatter-2d .graph")
    @axis1  = $("#hdu-#{@index} .scatter-2d select[data-axis=1]")
    @axis2  = $("#hdu-#{@index} .scatter-2d select[data-axis=2]")
    
    @saveButton = $("#hdu-#{@index} .scatter-2d button[name=save]")
    @saveButton.prop('disabled', true)
    
  render: ->
    attrs = {columns: @columns, name: @name, axes: 2}
    @html require('views/plot')(attrs)
    
  draw: =>
    index1 = @axis1.val()
    index2 = @axis2.val()
    
    if index1 is '-1' or index2 is '-1'
      @saveButton.prop('disabled', true)
      return null
    @saveButton.prop('disabled', false)
    
    @plot.empty()
    
    # Get labels for the axes
    xlabel = @axis1.find("option:selected").text()
    ylabel = @axis2.find("option:selected").text()
    
    # Get units if they are available
    header = @hdu.header
    unit1Key = "TUNIT#{parseInt(index1) + 1}"
    unit2Key = "TUNIT#{parseInt(index2) + 1}"
    xlabel += " (#{header[unit1Key]})" if header.contains(unit1Key)
    ylabel += " (#{header[unit2Key]})" if header.contains(unit2Key)
    
    @xdata = []
    @ydata = []
    
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
          
    @svg.selectAll(".dot")
        .data(@ydata)
      .enter().append("circle")
        .attr("class", "dot")
        .attr("r", 1.5)
        .attr("cx", (d, i) => return @x(@xdata[i]))
        .attr("cy", (d, i) => return @y(@ydata[i]))
        .on("mouseover", @showInfo)
        .on("mouseout", @hideInfo)
  
  showInfo: (d, i) =>
    item = d3.select(@svg.selectAll(".dot")[0][i])
    item.attr("r", 4)
    item.style("fill", d3.rgb(255, 0, 0))
    @info.html("(#{@formatter(@xdata[i])}, #{@formatter(@ydata[i])})")
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
    @svg.select(".x.axis").call(@xAxis)
    @svg.select(".y.axis").call(@yAxis)
    @svg.selectAll(".dot")
      .attr("cx", (d, i) => return @x(@xdata[i]))
      .attr("cy", (d, i) => return @y(@ydata[i]))
  
  savePlot: =>
    xlabel = @axis1.find("option:selected").text()
    ylabel = @axis2.find("option:selected").text()

    svg = @plot.find('svg')
    svg.attr('xmlns', 'http://www.w3.org/2000/svg')
    svg.attr('version', '1.1')
    window.URL = window.URL or window.webkitURL
    blob = new Blob([@plot.html()], {type: 'image/svg+xml'})

    a = document.createElement('a')
    a.download = "#{xlabel}_vs_#{ylabel}.svg"
    a.type = 'image/svg+xml'
    a.href = window.URL.createObjectURL(blob)
    a.click()
  
module.exports = Scatter2D