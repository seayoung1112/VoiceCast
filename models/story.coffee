mongoose = require("mongoose")

StorySchema = new mongoose.Schema
				author : {type: String, default: '杨老师', trim: true}
				audio: {uri: String}
				createAt: {type:Date, default:Date.now}

mongoose.model 'Story', StorySchema