const DB = require('../services/db_config');

const driverCheck = async (driver_id,driver_token,res) =>
{
  return await new Promise((resolve)=>{
    DB.pool.query('SELECT EXISTS(SELECT 1 FROM public."driver" WHERE "id"=($1) AND "token"=($2))',[driver_id,driver_token], (driverCheckError,checkResults)=>{
        if(driverCheckError)
        {
            DB.dbErrorHandler(res,driverCheckError);
        }
        else
        {
            if(!checkResults.rows[0].exists)
            {
                res.status(401).end();
            }
        }
        resolve(checkResults);
    });
  }); 
}

const managerCheck = async (manager_id, manager_token,res)=>
{
  return await new Promise((resolve)=>{
    DB.pool.query('SELECT EXISTS(SELECT 1 FROM public."manager" WHERE "id"=($1) AND "token"=($2))',[manager_id,manager_token], (managerCheckError,checkResults)=>{
        if(managerCheckError)
        {
            DB.dbErrorHandler(res,managerCheckError);
        }
        else
        {
            if(!checkResults.rows[0].exists)
            {
                res.status(401).end();
            }
        }
        resolve(checkResults);
    });
  }); 
}

const driverExistsCheck = async (driver_id,res) =>
{
  return await new Promise((resolve)=>{
    DB.pool.query('SELECT EXISTS(SELECT 1 FROM public."driver" WHERE "id"=($1))',[driver_id], (err,checkResults)=>{
        if(err)
        {
            DB.dbErrorHandler(res,err);
        }
        else
        {
            if(!checkResults.rows[0].exists)
            {
                res.status(404).end();
            }
        }
        resolve(checkResults); 
    });
  });
}

/*
This function is called when an attempt is made to mark a route as "complete", in order for a route to be completed a driver should have visited each delivery
address that formed part of the route. The app should of made an request each time a delivery address has been reached to store the time that the driver reached 
that location (delivery addresses will be refered to as locations from here on). If a location has no timestamp which indicates the time that the driver reached
said location then it means that the driver has potentially skipped a delivery on his route. His route can thus not be "completed". In this case
The api will still mark the route as completed, but it will be logged that the driver potentially skipped a delivery.
*/
const routeLocationsCheck = async (route_id,res) =>
{
  return await new Promise((resolve)=>{
    DB.pool.query('SELECT * FROM route."location" WHERE "route_id"=($1)',[route_id], (err,results)=>{
        if(err)
        {
            DB.dbErrorHandler(res,err);
            resolve(err);
        }
        else
        {
          let completed =  true;
          for(let k=0; k < results.rowCount;k++)
          {
            if(results.rows[k].timestamp_completed==null)
            {
              completed = false;
            }
          }
          resolve(completed);
        }
    });
  }); 
}

const centerPointExistsCheck = async (driver_id,sendResults,res) =>
{
  return await new Promise((resolve)=>{
    DB.pool.query('SELECT * FROM route."center_point" WHERE "driver_id"=($1)',[driver_id], (err,checkResults)=>{
        if(err)
        {
            DB.dbErrorHandler(res,err);
        }
        else
        {
            if(checkResults.rowCount > 0) //Driver allready has an existing centerpoint
            {
                if(sendResults)
                {
                  resolve(checkResults);
                }
                else
                {
                  res.status(409).end();
                }
            }
        }
        resolve(checkResults); 
    });
  });
}


module.exports = {driverCheck,routeLocationsCheck,managerCheck,driverExistsCheck,centerPointExistsCheck};
