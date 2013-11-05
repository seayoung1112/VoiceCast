
###
Module dependencies.
###
mongoose = require "mongoose"
fs = require "fs"
path = require "path"

# init db
mongoose.connect("mongodb://localhost/voicecast")

# add all models
model_path = __dirname + '/models'
for model_file in fs.readdirSync model_path
	require path.join(model_path, model_file)


express = require "express"
routes = require "./routes"
story = require "./routes/story"
http = require "http"
querystring = require "querystring"


app = express()

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", path.join(__dirname, "views")
app.set "view engine", "jade"

app.use express.compress()
app.use express.favicon()
app.use express.logger("dev")
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use express.cookieParser("asdgdgsewb233ssdf")
app.use express.session()
app.use express.csrf()
app.use (req, res, next) ->
    res.locals.csrf_qs = querystring.stringify _csrf : req.csrfToken()
    next()
app.use app.router
app.use require('connect-assets')()
app.use require("stylus").middleware(path.join(__dirname, "assets"))
app.use "/assets", express.static(path.join(__dirname, "assets"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")
app.get "/", routes.index
app.get "/story/new", story.new
app.post "/story/create", story.create
app.get "/story/show", story.show

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

