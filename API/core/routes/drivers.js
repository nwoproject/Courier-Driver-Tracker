const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const mailer = require('../services/mailer');
const DB = require('../services/db_config');
const bcrypt = require('bcrypt');

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
                        res.status(200).json({"id":results.rows[0].id,"token":results.rows[0].token}).end();
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
    DB.pool.query('SELECT * FROM public."driver" WHERE "id"=($1)',[driverID],(err,results)=>{
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
            if(results.rows[0].token!=req.body.token)
            {
                res.status(401).end();
                console.log(results.rows[0].token);
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

module.exports = router;
