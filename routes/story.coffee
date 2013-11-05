multiparty = require 'multiparty'
util = require '../util'
fs = require 'fs'
path = require 'path'
config = require '../config'
mongoose = require 'mongoose'
Story = mongoose.model 'Story'

exports.new = (req, res) ->
	res.render "story/new"

exports.create = (req, res) ->
	form = new multiparty.Form {uploadDir : config.tmpPath, autoFiles: true}
	console.log "form created"
	form.parse req, (err, fields, files) ->
		console.log err
		return res.json {error:err} if err
		console.log files
		destPath = path.join config.filePath, "audio", util.generateFilename()
		fs.renameSync files.audioFile[0].path, destPath
		story = new Story {title: fields.title}
		# story.save()
		res.send "ok"

exports.show = (req, res) ->
	res.render "story/show"