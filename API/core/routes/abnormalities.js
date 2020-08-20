const express = require('express');
const router = express.Router();
const DB = require('../services/db_config');
const format =  require('../utility/json_formatter');

const objectConvertor = (results) =>
{
    let code_100 = [];
    let code_101 = [];
    let code_102 = [];
    let code_103 = [];
    let code_104 = [];
    let code_105 = [];
    let code_106 = [];

    for(let k=0; k < results.rowCount;k++)
    {
        switch(results.rows[k].abnormality_code)
        {
            case 100: 
                code_100.push(abnormalitiesObjectCovertor(results , k));
                break;
            case 101:
                code_101.push(abnormalitiesObjectCovertor(results , k));
                break;
            case 102:
                code_102.push(abnormalitiesObjectCovertor(results , k));
                break;
            case 103:
                code_103.push(abnormalitiesObjectCovertor(results , k));
                break;
            case 104:
                code_104.push(abnormalitiesObjectCovertor(results , k));
                break;
            case 105:
                code_105.push(abnormalitiesObjectCovertor(results , k));
                break;
            case 106:
                code_106.push(abnormalitiesObjectCovertor(results , k));
                break;
        }
    }

    return {"driver_id" : results.rows[0].driver_id,
            "abnormalities" :
                {"code_100" : {
                    "code_description" : format.abnormalityDescription(100),
                    "driver_abnormalities" : code_100
                    },
                    "code_101" : {
                        "code_description" : format.abnormalityDescription(101),
                        "driver_abnormalities" : code_101
                    },
                    "code_102" : {
                        "code_description" : format.abnormalityDescription(102),
                        "driver_abnormalities" : code_102
                    },
                    "code_103" : {
                        "code_description" : format.abnormalityDescription(103),
                        "driver_abnormalities" : code_103
                    },
                    "code_104" : {
                        "code_description" : format.abnormalityDescription(104),
                        "driver_abnormalities" : code_104
                    },
                    "code_105" : {
                        "code_description" : format.abnormalityDescription(105),
                        "driver_abnormalities" : code_105
                    },
                    "code_106" : {
                        "code_description" : format.abnormalityDescription(106),
                        "driver_abnormalities" : code_106
                    }
                }
            };
}

const abnormalitiesObjectCovertor = (results,k) =>
{   
    return {"driver_description" : results.rows[k].driver_description,
            "latitude": results.rows[k].latitude,
            "longitude": results.rows[k].longitude,
            "timestamp": results.rows[k].datetime};
}

// POST /api/abnormalities/:driverid    
router.post('/:driverid',(req,res)=>{
    const driverID = req.params.driverid;
    if(!req.body.timestamp || !req.body.token || !req.body.latitude || !req.body.longitude || !req.body.code)
    {
        res.status(400).end();
    }
    else
    {
        const description = format.abnormalityDescription(req.body.code);
        if(description=='error') //Invalid abnormality code
        {
            res.status(400).end();
        }
        else
        {
            DB.pool.query('SELECT EXISTS(SELECT 1 FROM public."driver" WHERE "id" =($1) AND "token"=($2))',[driverID,req.body.token],(err,drivercheck)=>{
                if(err)
                {
                    DB.dbErrorHandler(res,err);
                }
                else
                {
                    if(drivercheck.rows[0].exists)
                    {
                        DB.pool.query('INSERT INTO public."abnormality"("driver_id","abnormality_code","description","driver_description","datetime","latitude","longitude")VALUES($1,$2,$3,$4,$5,$6,$7)',
                        [driverID,req.body.code,description,req.body.description,req.body.timestamp,req.body.latitude,req.body.longitude],(insertErr,insertRes)=>{
                            if(insertErr)
                            {
                                DB.dbErrorHandler(res,insertErr);
                            }
                            else
                            {
                                res.status(201).end();
                            }
                        });
                    }
                    else //Driver id and token does not match
                    {   
                        res.status(401).end();
                    }
                }
            });
        }
    }
});

// GET /api/abnormalities/:driverid
router.get('/:driverid',(req,res)=>{
    const driverID = req.params.driverid;
    DB.pool.query('SELECT * FROM public."abnormality" WHERE "driver_id"=($1)',[driverID],(err,results)=>{
        if(err)
        {
            DB.dbErrorHandler(res,err);
        }
        else
        {
            if(results.rowCount==0) //no abnormalities for that driver
            {
                res.status(204).end();
            }
            else
            {
                const responseBody = objectConvertor(results);
                res.status(200).json(responseBody).end();
            }
        }
    });
});

module.exports = router;
