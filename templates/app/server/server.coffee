port =  process.env.PORT || 9294

express = require('express')
fs = require('fs')
Routes = require("./routes")
Opfserver = require("opfcli")

##Setup Server
app = express.createServer()
app.use express.logger()
app.use express.bodyParser()
app.use express.cookieParser()

app.set 'view engine'  , 'jade'
app.set 'views' , './views'

app.user Opfserver.middleware()      
app.use(express.static("./public"))

routes = new Routes(app)

app.listen(port)
console.log "Listening on port " + port

