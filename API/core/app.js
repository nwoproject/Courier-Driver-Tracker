const logger = require('morgan');
const express = require('express');
const router = require('./routes/index');
const app = express();
const cors = require('cors');
const cron = require('node-cron');
const tasks = require('./utility/daily_tasks');

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

//At 23:59 on every day-of-week from Monday through Friday.
// Performs DB maintenence, moves todays routes and locations over to logs and check if all routes for the day has been completed.
cron.schedule('59 23 * * *', async () => 
{
  tasks.logTodaysRoutes();
},{
  scheduled: true,
  timezone: "Africa/Johannesburg"
});

//At 02:00 on every day-of-week from Monday through Friday.”
// Assigns daily routes to drivers.
cron.schedule('00 02 * * 1-5', () => 
{
  tasks.assignReaptingRoutes('daily');
},{
  scheduled: true,
  timezone: "Africa/Johannesburg"
});

module.exports = app;
