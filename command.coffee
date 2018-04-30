{asset_directory, basedir, appRequire, configDir} = global.config
{join, resolve} = require 'path'
{findSymbol} = require 'geologic-patterns'
{readFileSync, writeFileSync} = require 'fs'
{JSDOM} = require 'jsdom'
colors = require 'colors'
{parse} = require 'css'
d3 = require 'd3'

command = 'create-patterns'
describe = 'Create fill patterns'

handler = ->
  console.log "Creating fill patterns"
  outputDir = resolve join(configDir, asset_directory)
  {db, sql} = appRequire('src/util')

  assets = await db.query sql(join(__dirname,'sql/get-assets.sql'))

  for {id, fgdc_symbol, color, symbol_color} in assets
    sym = findSymbol(fgdc_symbol+'.svg')
    dom = new JSDOM readFileSync sym, 'utf-8'
    v = d3.select(dom.window.document.documentElement)
    svg = v.select("svg")

    color ?= 'transparent'

    console.log symbol_color
    if symbol_color?
      svg.selectAll("*").each (d)->
        el = d3.select @
        style = el.attr('style')

        for i in ['fill','stroke']
          fill = el.attr(i)
          if fill?
            el.attr i, symbol_color

        # Parse the style object
        return unless style?
        obj = {}
        for kv in style.split(";")
          continue if kv == ""
          [k,v] = kv.split(":")
          obj[k] = v

        for k,v of obj
          el.style k,v
        ## Check if filled ##
        if (obj.fill? and obj.fill != 'none')
          el.style 'fill', symbol_color

        ## Check if filled ##
        if (obj.stroke? and obj.stroke != 'none')
          el.style 'stroke', symbol_color


      svg.selectAll("g").each (d)->
        d3.select @
          .style 'fill', symbol_color

      svg.insert 'rect', ':first-child'
        .attr 'width', 1000
        .attr 'height', 1000
        .attr 'x', -500
        .attr 'y', -500
        .style 'fill', color

    outfn = join(outputDir, id+'.svg')
    console.log outfn.green
    writeFileSync outfn, svg.node().outerHTML, 'utf-8'

  console.log "Done"
  process.exit(0)

module.exports = {command, describe, handler}



