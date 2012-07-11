Madmimi = require ('./libs/madmimi');
jade = require('jade');


class EmailController

  constructor: (@app) ->
    @madmimi = new Madmimi(process.env.MADMIMI_EMAIL , process.env.MADMIMI_API_KEY, true);
    @app.use @middleware()

  middleware: =>
    return (req,res,next)  =>
      console.log "email pass"
      req.emailController = @
      next()

  sendEmail: ( to , subject , template , text, callback ) =>
    jade.renderFile process.cwd() + "/templates/#{template}.jade" , {text: text} ,  (err, html) =>
    
      options =
        promotion_name: template,
        recipient: to
        subject: subject
        from: "dino@jungledynamics.com",      
        raw_html: html

      @madmimi.sendMail options , callback 

module.exports= EmailController