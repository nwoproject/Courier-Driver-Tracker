const logger = require('morgan');
const express = require('express');
const router = require('./routes/index');
const app = express();
const cors = require('cors');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

let whitelist = [process.env.LOCAL_WEB_URL, process.env.DEPLOYED_WEB_URL]
app.use(cors({
  origin: function(origin, callback){
    if(!origin) return callback(null, true);
    if(whitelist.indexOf(origin) === -1){
      var message = `Cors policy blocks requests from this domain`;
      return callback(new Error(message), false);
    }
    return callback(null, true);
  }
}));

app.use('/api', router);

 app.use((req, res, next) => {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
  });


app.use((err, req, res, next) => {
    console.log(err.stack);
    res.status(err.status || 500);
        res.json({'errors': {
        message: err.message,
        error: err
    }});
}); 

module.exports = app;
