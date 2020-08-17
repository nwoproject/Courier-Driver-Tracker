const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const mailer = require('../services/mailer');
const DB = require('../services/db_config');
const bcrypt = require('bcrypt');
const checks = require('../utility/database_checks');
const db_query = require('../utility/common_queries');
const format = require('../utility/json_formatter');

// POST /api/drivers
router.post('/', (req, res) =>{ 
    var driverPassword = crypto.randomBytes(4).toString('hex');
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if(!re.test(req.body.email))
    {
      res.status(400).end();
    }
    DB.pool.query('SELECT EXISTS(SELECT 1 FROM public."driver" WHERE "email" =($1))',[req.body.email],(err,results)=>{
        if(err)
        {
            DB.dbErrorHandler(res,err);
        }
        else
        {
            if(results.rows[0].exists)
            {
                res.status(409).end();
            }
            else
            {
                var token = crypto.randomBytes(46).toString('base64').replace(/\//g,'_').replace(/\+/g,'-');
                const tokenGenerator = () =>
                {
                    DB.pool.query('SELECT EXISTS(SELECT 1 FROM public."driver" WHERE "token" =($1))',[token],(error,tokenres)=>{
                        if(error)
                        {
                            dbErrorHandler(res,error);
                        }
                        if(!tokenres.rows[0].exists)
                        {
                            return token;
                        }
                        else //Token allready exists, generates new token.
                        {
                            token = crypto.randomBytes(46).toString('base64').replace(/\//g,'_').replace(/\+/g,'-');
                            tokenGenerator(); 
                        }
                    });
                };
                tokenGenerator();
                bcrypt.hash(driverPassword, 10, (hasherr, hash)=>{
                    DB.pool.query('INSERT INTO public."driver"("email","password","name","surname","token","epoch")VALUES($1,$2,$3,$4,$5,$6)',[req.body.email,hash,req.body.name,req.body.surname,token,Math.floor(new Date() / 1000)],(error,insertResult)=>{
                        if(error)
                        {
                            dbErrorHandler(res,error);
                        }
                        else
                        {
                            var driverEmail = mailer.driverMessage(req.body.email,driverPassword);
                            mailer.mailer(driverEmail);
                            res.status(201).end();
                        }
                    });
                });
            }
        }
    });
});

// POST api/drivers/authenticate
router.post('/authenticate', (req, res) =>{
    DB.pool.query('SELECT * FROM public."driver" WHERE "email"=($1)',[req.body.email],(err,results)=>{
        if(err)
        {
          DB.dbErrorHandler(res,err);
        }
        else
        {
            if(results.rowCount==0)
            {
                res.status(404).end();
            }
            else
            {
                bcrypt.compare(req.body.password,results.rows[0].password,(bcryptError,passResult)=>{
                    if(bcryptError)
                    {
                        DB.dbErrorHandler(res,bcryptError);
                    }
                    if(passResult)
                    {
                        res.status(200).json({"id":results.rows[0].id,"token":results.rows[0].token,"name":results.rows[0].name,"surname":results.rows[0].surname}).end();
                    }
                    else
                    {
                        res.status(401).end();
                    }
                });
            }
        }
    });
});

// PUT api/drivers/:driverid/password
router.put('/:driverid/password', (req, res) =>{
    const driverID = req.params.driverid;
    DB.pool.query('SELECT * FROM public."driver" WHERE "id"=($1) AND "token"=($2)',[driverID,req.body.token],(err,results)=>{
        if(err)
        {
            DB.dbErrorHandler(res,err);
        }
        else
        {
            if(results.rowCount==0)
            {
                res.status(404).end();
            }
            else
            {
                bcrypt.hash(req.body.password, 10, (hasherr, hash)=>{
                    if(hasherr)
                    {
                        DB.dbErrorHandler(res,hasherr);
                    }
                    else
                    {
                        DB.pool.query('UPDATE public."driver" SET "password"=($1) WHERE "id"=($2) AND "token"=($3)',[hash,driverID,req.body.token],(updateError,updateResults)=>{
                            if(updateError)
                            {
                                DB.dbErrorHandler(res,updateError);
                            }
                            else
                            {
                                if(updateResults.rowCount==1)
                                {
                                    res.status(204).end();
                                }
                                else
                                {
                                    res.status(500).end();
                                }
                            }
                        });
                    }
                });
            }
        }
    });
});

// DELETE api/drivers/:driverid
router.delete('/:driverid',async (req,res)=>{
    const driverID = req.params.driverid;
    if(!req.body.token)
    {
        res.status(400).end();
    }
    else // check if valid manager or valid driver made the request
    {
        if(req.body.manager === true) // delete request from manager
        {
            DB.pool.query('SELECT EXISTS(SELECT 1 FROM public."manager" WHERE "token"=($1) AND "id"=($2))',[req.body.token,req.body.id],(err,existsres)=>{
                if(err)
                {
                    DB.dbErrorHandler(res,err);
                }
                else
                {
                    if(existsres.rows[0].exists)
                    {
                        DB.pool.query('DELETE FROM public."driver" WHERE "id"=($1) RETURNING *',[driverID],(deletErr,deleteRes)=>{
                            if(deletErr)
                            {
                                DB.dbErrorHandler(res,deletErr);
                            }
                            else 
                            {
                                if(deleteRes.rowCount==1) // record deleted
                                {
                                    res.status(200).end();
                                }
                                else // invalid driver id
                                {
                                    res.status(404).end();
                                }
                            }   
                        });
                    }
                    else
                    {
                        res.status(401).end();
                    }
                }
            });
        }
        else // delete request from driver
        {
            if(req.body.manager===false)
            {
                DB.pool.query('DELETE FROM public."driver" WHERE "id"=($1) AND "token"=($2) RETURNING *',[driverID,req.body.token],(deletErr,deleteRes)=>{
                    if(deletErr)
                    {
                        DB.dbErrorHandler(res,deletErr);
                    }
                    else 
                    {
                        if(deleteRes.rowCount==1) // record deleted
                        {
                            res.status(200).end();
                        }
                        else // invalid token or driver id
                        {
                            res.status(401).end();
                        }
                    } 
                });
            }
            else
            {
                res.status(400).end();
            }
        }
    }
});

// PUT api/drivers/forgotpassword
router.put('/forgotpassword',(req,res)=>{
    const driverPassword = crypto.randomBytes(4).toString('hex');
    bcrypt.hash(driverPassword, 10, (hasherr, hash)=>{
        DB.pool.query('UPDATE public."driver" SET "password"=($1) WHERE "email"=($2)',[hash,req.body.email],(updateError,updateResults)=>{
            if(updateError)
            {
                DB.dbErrorHandler(res,updateError);
            }
            else
            {
                if(updateResults.rowCount==1)
                {
                    const driverEmail = mailer.driverForgotPassword(req.body.email,driverPassword);
                    mailer.mailer(driverEmail);
                    res.status(204).end();
                }
                else
                {
                    res.status(404).end();
                }
            }
        });
    });
});

// POST api/drivers/centerpoint
router.post('/centerpoint',async (req,res)=>{
    if(!req.body.id || !req.body.driver_id || !req.body.token || !req.body.radius || !req.body.latitude || !req.body.longitude)
    {
        res.status(400).end();
    }
    else
    {
        await checks.managerCheck(req.body.id,req.body.token,res);
        if(!res.writableEnded)
        {
            await checks.driverExistsCheck(req.body.driver_id,res);
            if(!res.writableEnded)
            {
                await checks.centerPointExistsCheck(req.body.driver_id,false,res);
                if(!res.writableEnded)
                {
                    DB.pool.query('INSERT INTO route."center_point"("driver_id","latitude","longitude","radius")VALUES($1,$2,$3,$4)',[req.body.driver_id,req.body.latitude,req.body.longitude,req.body.radius],(err,results)=>{
                        if(err)
                        {
                            DB.dbErrorHandler(res,err);
                        }
                        else
                        {
                            res.status(201).end();
                        }
                    });
                }
            }
        }
    }   
});

// PUT api/drivers/centerpoint/radius
router.put('/centerpoint/radius',async (req,res)=>{
    if(!req.body.id || !req.body.driver_id || !req.body.token || !req.body.radius)
    {
        res.status(400).end();
    }
    else
    {
        await checks.managerCheck(req.body.id,req.body.token,res);
        if(!res.writableEnded)
        {
            DB.pool.query('UPDATE route."center_point" SET "radius"=($1) WHERE "driver_id"=($2)',[req.body.radius,req.body.driver_id],(err,results)=>{
                if(err)
                {
                    DB.dbErrorHandler(res,err);
                }
                else
                {
                    if(results.rowCount==1)
                    {
                        res.status(204).end();
                    }
                    else
                    {
                        res.status(404).end();
                    }
                }
            });
        }
    }
});

// PUT api/drivers/centerpoint/coords
router.put('/centerpoint/coords',async (req,res)=>{
    if(!req.body.id || !req.body.driver_id || !req.body.token || !req.body.latitude || !req.body.longitude)
    {
        res.status(400).end();
    }
    else
    {
        await checks.managerCheck(req.body.id,req.body.token,res);
        if(!res.writableEnded)
        {
            DB.pool.query('UPDATE route."center_point" SET "latitude"=($1),"longitude"=($2) WHERE "driver_id"=($3)',[req.body.latitude,req.body.longitude,req.body.driver_id],(err,results)=>{
                if(err)
                {
                    DB.dbErrorHandler(res,err);
                }
                else
                {
                    if(results.rowCount==1)
                    {
                        res.status(204).end();
                    }
                    else
                    {
                        res.status(404).end();
                    }
                }
            });
        }
    }
});

// DELETE api/drivers/centerpoint/:driverid
router.delete('/centerpoint/:driverid',async (req,res)=>{
    if(!req.body.id || !req.body.driver_id || !req.body.token)
    {
        res.status(400).end();
    }
    else
    {
        await checks.managerCheck(req.body.id,req.body.token,res);
        if(!res.writableEnded)
        {
            DB.pool.query('DELETE FROM route."center_point" WHERE "driver_id"=($1) RETURNING *',[req.body.driver_id],(deletErr,deleteRes)=>{
                if(deletErr)
                {
                    DB.dbErrorHandler(res,deletErr);
                }
                else 
                {
                    if(deleteRes.rowCount==1) // record deleted
                    {
                        res.status(200).end();
                    }
                    else 
                    {
                        res.status(404).end();
                    }
                } 
            });
        }
    }
});

// POST api/drivers/centerpoint/:driverid
router.post('/centerpoint/:driverid',async (req,res)=>{
    const driver_id = req.params.driverid;
    if(!req.body.id || !req.body.token)
    {
        res.status(400).end();
    }
    else
    {
        await checks.managerCheck(req.body.id,req.body.token,res);
        if(!res.writableEnded)
        {
            const centerpoint = await checks.centerPointExistsCheck(driver_id,true,res);
            if(!res.writableEnded && centerpoint.rowCount==0)
            {
                res.status(404).end();
            }
            if(!res.writableEnded)
            {
                const driver = await db_query.getDriver(driver_id);
                res.status(200).json(format.getDriverCentrePointResponse(centerpoint,driver));
            }
        }
    }
});

module.exports = router;
