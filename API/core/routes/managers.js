const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const DB = require('../services/db_config');
const bcrypt = require('bcrypt');

// POST /api/managers
router.post('/', (req, res) =>{ 
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if(!re.test(req.body.email))
    {
      res.status(400).end();
    }
    DB.pool.query('SELECT EXISTS(SELECT 1 FROM public."manager" WHERE "email" =($1))',[req.body.email],(err,results)=>{
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
                    DB.pool.query('SELECT EXISTS(SELECT 1 FROM public."manager" WHERE "token" =($1))',[token],(error,tokenres)=>{
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
                bcrypt.hash(req.body.password, 10, (hasherr, hash)=>{
                    DB.pool.query('INSERT INTO public."manager"("email","password","name","surname","token","epoch")VALUES($1,$2,$3,$4,$5,$6) RETURNING *',[req.body.email,hash,req.body.name,req.body.surname,token,Math.floor(new Date() / 1000)],(error,insertResult)=>{
                        if(error)
                        {
                            dbErrorHandler(res,error);
                        }
                        else
                        {
                            res.status(201).json({"id":insertResult.rows[0].id,"token":insertResult.rows[0].token});
                        }
                    });
                });
            }
        }
    });
});

// POST /api/managers/authenticate
router.post('/authenticate', (req, res) =>{
    DB.pool.query('SELECT * FROM public."manager" WHERE "email"=($1)',[req.body.email],(err,results)=>{
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

module.exports = router;
