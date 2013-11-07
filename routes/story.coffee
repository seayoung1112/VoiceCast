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
		console.log files.audioFile
		return res.json {error:err} if err?
		return res.json {error: 'no file attached'} unless files.audioFile?
		randomFilename = util.generateFilename()
		destPath = path.join config.filePath, "audio", randomFilename
		fs.renameSync files.audioFile[0].path, destPath
		story = new Story {title: fields.title, audio: 
			uri : "/assets/audio/#{randomFilename}"
			path: destPath
		}
		story.save (err) ->
			return res.send story.title unless err?
			fs.unlinkSync destPath
			res.json error: require('util').inspect err.errors

exports.list = (req, res) ->
	Story.find {}, (err, stories) ->
		res.render "story/list", stories:stories
			
exports.show = (req, res) ->
	res.render "story/show"

exports.delete = (req, res) ->
	console.log req.params.id
	Story.remove _id : req.params.id , (err) ->
		if err? then res.json {err:err} else res.send "ok"