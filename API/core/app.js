const logger = require('morgan');
const express = require('express');
const router = require('./routes/index');

const app = express();

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

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
