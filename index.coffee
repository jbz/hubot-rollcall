fs   = require 'fs'
path = require 'path'

module.exports = (robot, scripts) ->
  scriptsPath = path.resolve(__dirname, 'src')
  fs.exists scriptsPath, (exists) ->
    if exists
      for script in rs.readdirSync(scriptsPath)
      robot.loadFile(scriptsPath, script) if script in scripts
    else
      robot.loadFile(scriptsPath, script)
