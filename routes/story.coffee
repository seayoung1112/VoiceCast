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
	form.parse req, (err, fields, files) ->
		return res.json {error:err} if err?
		return res.json {error: 'no file attached'} unless files.audioFile?
		destPath = path.join config.filePath, "audio", util.generateFilename()
		fs.renameSync files.audioFile[0].path, destPath
		story = new Story {title: fields.title}
		story.save (err) ->
			return res.send "ok" unless err?
			fs.unlinkSync destPath
			res.json error: require('util').inspect err.errors
			
exports.show = (req, res) ->
	res.render "story/show"