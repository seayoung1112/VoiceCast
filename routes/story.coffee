Busboy = require 'busboy'

exports.new = (req, res) ->
	res.render "story/new"

exports.create = (req, res) ->
	busboy = new Busboy headers: req.headers
	fileFields = {}
	busboy.on 'file', (fieldname, file, filename, encoding, mime) ->
		console.log "fieldname: #{fieldname}. filename: #{filename}"
		fileFields[fieldname] = filename
		file.on 'data', (data) ->
			console.log "file got #{data.length} bytes"
		file.on 'end', ->
			console.log "file upload finished!"
	busboy.on 'end', ->
		console.log "parse finished"
		res.json fileFields 
	req.pipe busboy

exports.show = (req, res) ->
	res.render "story/show"