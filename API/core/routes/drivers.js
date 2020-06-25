/* /api/users */
const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const mailer = require('../services/mailer');
const DB = require('../services/db_config');
const bcrypt = require('bcrypt');
const { dbErrorHandler } = require('../services/db_config');

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
                var token = crypto.randomBytes(32).toString('hex');
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
                        else // Token already exists, generates a new token and calls function again
                        {
                            token = crypto.randomBytes(32).toString('hex');
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

router.post('/authenticate', (req, res) =>{
    res.status(202).send("authenticate pass").end();
});

router.put('/:driverid/password	', (req, res) =>{
    res.status(202).send("update password").end();
});


module.exports = router;
