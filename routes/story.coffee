multiparty = require 'multiparty'
fs = require 'fs'
mongoose = require 'mongoose'
Story = mongoose.model 'Story'

exports.new = (req, res) ->
	res.render "story/new"

exports.create = (req, res) ->
	form = new multiparty.Form()
	form.parse req, (err, fields, files) ->
		return res.json {error:err} if err
		console.log files.audioFile[0].path
		res.json files
		# fs.rename()
		story = new Story {title: fields.title}

exports.show = (req, res) ->
	res.render "story/show"