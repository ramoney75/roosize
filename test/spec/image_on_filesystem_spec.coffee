ImageOnFilesystem = require('image_on_filesystem').ImageOnFilesystem
Configuration = require('configuration').Configuration
FakeHttpResponse = require('fake_http_response').FakeHttpResponse

gd = require 'node-gd'
fs = require 'fs'

describe 'ImageOnFileSystem', ->
  _imageFile = null
  _fakeHttpResponse = new FakeHttpResponse

  beforeEach ->
    _imageFile = null

    _imageFile = new ImageOnFilesystem(new Configuration('./test/fixtures/full_config.json'), _fakeHttpResponse)
    _imageFile.open 'images/black_square.jpg', ->
      _imageFile.data

    waitsFor ->
      _imageFile.data?

  it 'should have a modified time', ->
    modified = fs.statSync('./test/fixtures/images/black_square.jpg').mtime
    expect(modified).toBeLessThan(new Date)
    expect(_imageFile.modified).toEqual(modified)

  describe 'file format', ->
    it('should have a stringified type', ->
      expect(_imageFile.type).toEqual('jpeg')
    )

    it('should have a mime type', ->
      expect(_imageFile.mimeType).toEqual('image/jpeg');
    )

  it 'should have some image data', ->
    expect(_imageFile.data.width).toEqual(100)
    expect(_imageFile.data.height).toEqual(100)

  it 'should write back to the client', ->
    expect(_fakeHttpResponse.code).toEqual(200)
    expect(_fakeHttpResponse.headers['Content-Type']).toEqual('image/jpeg')
    expect(gd.createFromJpegPtr(_fakeHttpResponse.body).width).toEqual(100)

describe 'Missing ImageOnFileSystem', ->
  _fakeResponse = new FakeHttpResponse

  beforeEach ->
      imageFile = new ImageOnFilesystem(new Configuration('./test/fixtures/minimal_config.json'), _fakeResponse)
      imageFile.open 'images/does_not_exist.jpg'

      waitsFor ->
        _fakeResponse.code == 404

  it 'should respond with a 404 when an image is not found', ->
    expect(_fakeResponse.code).toEqual(404)
    expect(_fakeResponse.body).toEqual('No such file on disk images/does_not_exist.jpg')