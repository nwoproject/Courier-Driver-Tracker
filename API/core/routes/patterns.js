const { response } = require('express');
const express = require('express');
const router = express.Router();
const DB = require('../services/db_config');
const checks = require('../utility/database_checks');

router.post('/weekly/:driverid', async (req,res)=>{
    const driverID =  req.params.driverid;
    const datetime =  new Date(new Date() + 'GMT');
    const patternDate = datetime.toISOString().slice(0,10);
    
    await checks.driverExistsCheck(driverID,res);

    if(!res.writableEnded)
    {
        DB.pool.query('INSERT INTO ai."weekly_pattern"("pattern_detected","abnormality","day","date","driver_id")VALUES($1,$2,$3,$4,$5)',
        [req.body.patternsDetected,req.body.abnormalities,req.body.days,patternDate,driverID],(err,results)=>{
            if(err)
            {
                DB.dbErrorHandler(res,err);
            }
            else
            {
                res.status(200).end();
            }
        });
    }
});



router.get('/report/:time',async(req,res)=>{
    const TimeVar = req.params.time;
    let MyDate = new Date();
    let Request = '';
    if(TimeVar==="week"){
        MyDate.setDate(MyDate.getDate() - 7);
        Request = 'SELECT * FROM ai."weekly_pattern" where "date">($1)';
    }
    else if(TimeVar==="month"){
        MyDate.setDate(MyDate.getDate() - 30);
        Request = 'SELECT * FROM ai."monthly_pattern" where "date">($1)';
    }
    else{
        res.status(400).end();
    }
    DB.pool.query(Request,[MyDate],(err,result)=>{
        if(err){
            DB.dbErrorHandler(res,err);
        }
        else{
            if(result.rowCount==0){
                res.status(204).end();
            }
            else{
                res.status(200).json(result.rows).end();
            }
        }
    });
});
module.exports = router;