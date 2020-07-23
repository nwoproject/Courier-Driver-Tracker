const express = require('express');
const router = express.Router();
const dotenv = require('dotenv').config();

const BEARER_TOKEN = process.env.BEARER_TOKEN;

/* 
  Middleware function to check for a valid Authentication Bearer <token>
  according to JWT standards
*/
router.use((req, res, next) => {
    if(req.headers && req.headers["authorization"])
    {
      var value = req.headers["authorization"].split(' ');
      if(value.length === 2 && value[0]==="Bearer")
      {
        var token = value[1];
        if(token===BEARER_TOKEN)
        {
          next();
        }
        else
        {
          res.status(401).end();
        }
      }
      else
      {
        res.status(401).end();
      }
    }
    else
    {
      res.status(401).end();
    }
});

router.use('/drivers', require('./drivers'));
router.use('/managers', require('./managers'));
router.use('/location', require('./location'));
router.use('/routes', require('./driver_routes'));
router.use('/google-maps', require('../services/google_maps'));

module.exports = router;
