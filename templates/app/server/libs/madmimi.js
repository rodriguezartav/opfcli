var https = require('https'),
    http = require('http'),
    querystring = require('querystring'),
    xml2js = require('xml2js'),
    jade = require('Jade');


var Madmimi = module.exports = function (username, api_key, debug) {

  if (debug) {
    logger = console.log;
  }  else {
    logger = function () {};
  }

  if (!username || !api_key) {
    throw("need to specify username and api key")
  }

  var self = this;

  self.username = username,
    self.api_key = api_key;

  self.request = function(requestOptions, body, cb) {

    var httpClient = requestOptions.port === '443' ?  https : http;

    if (requestOptions.method == 'POST') {
      requestOptions.headers = {'content-type': 'application/x-www-form-urlencoded'};
    }

    if(!cb) { cb = function () {} };

    var httpBody = undefined

      if (arguments.length > 2) {
        httpBody = body; 
        logger("httpBody: " + httpBody); 
      }


    var req = httpClient.request(requestOptions, function(res) {
      res.body = "";

      logger('STATUS: ' + res.statusCode);
      logger('HEADERS: ' + JSON.stringify(res.headers));

      res.setEncoding('utf8');
      res.on('data', function (chunk) {
        logger('BODY: ' + chunk);
        res.body += chunk;
      });

      res.on('end', function () {
        logger('end');        
        cb(res.body);
      });
    });

    if(httpBody) {
      req.write(optionsParameterized);
    };

    req.end();
  };


  function _sendMail(options, cb) {
     optionsParameterized = querystring.stringify(options, "&", "=");

    var requestOptions = {
      host: 'api.madmimi.com',
      port: '443',
      path: '/mailer',
      method: 'POST'
    };

    self.request(requestOptions, optionsParameterized, cb);
  };

  self.sendMail = function (options, cb) {
    options.username = self.username;
    options.api_key = self.api_key;

    if (options.jade) {
      jade.renderFile(options.jade, function(err, html){
        if(err) throw err;

        delete options.jade;
        options.raw_html = html;
        _sendMail(options, cb);
      });
    } else {
      _sendMail(options, cb);
    }
   
  };

  self.mailStatus = function(id, cb) {
    options = {
      username: self.username,
      api_key: self.api_key
    };

    optionsParameterized = querystring.stringify(options, "&", "=");
    transactionPath =  '/mailers/status/'+ id +'?' + optionsParameterized;

    var requestOptions = {
      host: 'madmimi.com',
      port: '443',
      path: transactionPath,
      method: 'GET',
    };

    self.request(requestOptions, optionsParameterized, cb);
  };

  self.promotions = function (cb) {
    options = {
      username: self.username,
      api_key: self.api_key
    };

    optionsParameterized = querystring.stringify(options, "&", "=");
    transactionPath =  '/promotions.xml' +'?' + optionsParameterized;

    var requestOptions = {
      host: 'api.madmimi.com',
      port: '443',
      path: transactionPath,
      method: 'GET',
    };

    xml_parser_cb = function (data) {
      logger("promotions_xml: " + data);

      var parser = new xml2js.Parser();

      parser.addListener('end', function(result) {
        logger("result_js:");
        logger(result);
        var promotions = result.promotion;

        cb(promotions);
      });

      parser.parseString(data);

    };

    self.request(requestOptions, optionsParameterized, xml_parser_cb);

  };

  self.addToList = function(email, listName, cb) {
    var options = {
      username : self.username,
      api_key : self.api_key,
      email : email,
    };


    optionsParameterized = querystring.stringify(options, "&", "=");

    var requestOptions = {
      host: 'api.madmimi.com',
      port: '80',
      path: "/audience_lists/" + listName  +'/add',
      method: 'POST',
    };

    self.request(requestOptions, optionsParameterized, cb);

  };


  return self;
};