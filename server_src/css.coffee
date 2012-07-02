fs = require('fs')
Less = require('less')  

class css
  
  @compile: (callback,mimified=false) ->
    try
      path = "./css/index.less"
      parser = new(Less.Parser)( { paths: ['./css/bootstrap', './css/'] , filename: 'index.less' } )
      fs.readFile path, "utf8" , (err, data) =>
        if err 
          console.error err
          callback("",false)
        parser.parse data, (err, css) ->
          if err
            console.error err
            callback("",false)
          else  
            content = css.toCSS()
            content = content.replace(/(\s)+/g, "$1") if mimified
            callback(content,true)
    catch err
      callback "",false
        
module.exports = css