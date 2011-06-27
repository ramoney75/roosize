require.paths.unshift([__dirname, 'lib'].join('/'))

http = require 'http'

Configuration = require('configuration').Configuration
ImageOnFilesystem = require('image_on_filesystem').ImageOnFilesystem
ResizeFactory = require('resize_factory').ResizeFactory
Request = require('request').Request
e = require 'exception_reporter'

#TODO: make this more robust
configFile = process.argv[2]
unless configFile?
  console.warn('Missing parameter: config file')
  process.exit(-1)

config = new Configuration(configFile)

http.Agent.defaultMaxSockets = config.connectionLimit

http.createServer((httpRequest, httpResponse) ->

  try
    request = new Request(httpRequest.url, config, httpResponse)
    imageFile = new ImageOnFilesystem(config, httpResponse)

    imageFile.open(request.path, ->
      resizeFactory = new ResizeFactory(config, request, httpResponse)
      resizeFactory.instance.resize(request, imageFile.data)
    )
  catch err
    e.reportUnknownException(err, httpResponse)

).listen(config.listenPort)

console.log('Listening on port ' + config.listenPort)