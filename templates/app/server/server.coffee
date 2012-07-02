port =  process.env.PORT || 9294

express = require('express')
fs = require('fs')
Routes = require("./routes")
Opfserver = require("opfserver")

##Setup Server
app = express.createServer()
app.use express.logger()
app.use express.bodyParser()
app.use express.cookieParser()
app.set 'view engine'  , 'jade'
app.set 'views' , './views'

Opfserver.setupRoutes(app) if process.env.NODE_ENV != "production"
      
app.use(express.static("./public"))

routes = new Routes(app)

app.listen(port)
console.log "Listening on port " + port

