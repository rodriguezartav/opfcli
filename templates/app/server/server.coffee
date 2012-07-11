port =  process.env.PORT || 9294

express = require('express')
fs = require('fs')
Routes = require("./routes")
Opfserver = require("opfcli")
#TwitterController = require('./twitterController')
#EmailController = require('./emailController')
#ParseController = require('./parseController')



##Setup Server
app = express.createServer()
app.use express.logger()
app.use express.bodyParser()
app.use express.cookieParser()
#new RedisController(app)


app.set 'view engine'  , 'jade'
app.set 'views' , './views'

app.user Opfserver.middleware()      
app.use(express.static("./public"))

#new EmailController(app)
#new ParseController(app)    
#new TwitterController(app)

routes = new Routes(app)

app.listen(port)
console.log "Listening on port " + port

