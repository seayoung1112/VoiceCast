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
	form = new multiparty.Form uploadDir : config.tmpPath, autoFiles: true
	form.parse req, (err, fields, files) ->
		return res.json {error:err[0].Error} if err?
		return res.json {error: 'no file attached'} unless files.audioFile?
		randomFilename = util.generateFilename()
		destPath = path.join config.filePath, "audio", randomFilename
		fs.renameSync files.audioFile[0].path, destPath
		story = new Story {title: fields.title, audio: 
			uri : "/assets/audio/#{randomFilename}"
			path: destPath
		}
		story.save (err) ->
			return res.json story unless err?
			fs.unlinkSync destPath
			res.json error: require('util').inspect err.errors

exports.list = (req, res) ->
	Story.find {}, (err, stories) ->
		res.render "story/list", stories:stories
			
exports.show = (req, res) ->
	Story.findById req.params.id, (err, story) ->
		res.render "story/show", story : story

exports.delete = (req, res) ->
	Story.remove _id : req.params.id , (err) ->
		if err?
			res.json {err:err}
		else
			fs.unlink destPath, (err) ->
				if err? then res.send "ok" else res.json {err:err}