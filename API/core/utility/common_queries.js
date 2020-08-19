const DB = require('../services/db_config');
const async = require('async');

const addRoute = async (route,driver_id,res,writable)=>
{
    return await new Promise((resolve)=>{
        const datetime =  new Date(new Date() + 'GMT');
        const assinged_Date = datetime.toISOString().slice(0,10);
        DB.pool.query('INSERT INTO route."route"("driver_id","completed","date_assigned")VALUES($1,$2,$3) RETURNING *',[driver_id,false,assinged_Date],(error,routeResult)=>{
            if(error)
            {
                if(writable)
                {
                    DB.dbErrorHandler(res,error);
                }
                else
                {
                    DB.dbErrorHandlerNoResponse(err);
                }
                resolve(error);
            }
            else
            {
                
               var series = [];
               for(var k=0; k < route.length;k++)
               {
                   series.push(k);
               }

               async.eachSeries(series,(i,callback)=>{
                    DB.pool.query('INSERT INTO route."location"("route_id","latitude","longitude","address","name")VALUES($1,$2,$3,$4,$5)',
                    [routeResult.rows[0].route_id,route[i].latitude,route[i].longitude,route[i].address,route[i].name],(locationError,locationResult)=>{
                        if(locationError)
                        {
                            DB.dbErrorHandlerNoResponse(locationError);
                        }
                        callback(null);
                    });
               },(insertErr)=>{
                    if(insertErr)
                    {
                        if(writable)
                        {
                            DB.dbErrorHandler(res,insertErr);
                        }
                        else
                        {
                            DB.dbErrorHandlerNoResponse(insertErr);
                        }
                        resolve(insertErr);
                    }
                    else
                    {
                        resolve();
                    }
               });
            }
        });
    }); 
}

const addRepeatingRoute = async (req,res)=>
{
    return await new Promise((resolve)=>{
        DB.pool.query('INSERT INTO route."repeating_route"("occurrence")VALUES($1) RETURNING *',[req.body.occurrence],(error,routeResult)=>{
            if(error)
            {
                DB.dbErrorHandler(res,error);
                resolve(error);
            }
            else
            {
                
               var series = [];
               for(var k=0; k < req.body.route.length;k++)
               {
                   series.push(k);
               }

               async.eachSeries(series,(i,callback)=>{
                    DB.pool.query('INSERT INTO route."repeating_location"("route_id","latitude","longitude","address","name")VALUES($1,$2,$3,$4,$5)'
                    ,[routeResult.rows[0].repeating_route_id,req.body.route[i].latitude,req.body.route[i].longitude,req.body.route[i].address,req.body.route[i].name],(locationError,locationResult)=>{
                        if(locationError)
                        {
                            DB.dbErrorHandlerNoResponse(locationError);
                        }
                        callback(null);
                    });
               },(insertErr)=>{
                    if(insertErr)
                    {
                        DB.dbErrorHandler(res,insertErr);
                        resolve(insertErr);
                    }
                    else
                    {
                        resolve();
                    }
               });
            }
        });
    }); 
}

const getCenterPoints = async (res)=>
{
    return await new Promise((resolve)=>{
        DB.pool.query('SELECT * FROM route."center_point"',[],(err,result)=>{
            if(err)
            {
                DB.dbErrorHandler(res,err);
            }
            resolve(result);
        });
    });
}

const getTodaysRoutes = async (res)=>
{
    const datetime = new Date(new Date() + 'GMT');
    const date = datetime.toISOString().slice(0,10);   
    return await new Promise((resolve)=>{
        DB.pool.query('SELECT "route_id","driver_id" FROM route."route" WHERE "date_assigned"=($1) ',[date],(err,result)=>{
            if(err)
            {
                DB.dbErrorHandler(res,err);
            }
            resolve(result);
        });
    });
}

const getDriver = async (driver_id)=>
{
    return await new Promise((resolve)=>{
        DB.pool.query('SELECT "name","surname" FROM public."driver" WHERE id=($1) ',[driver_id],(err,result)=>{
            if(err)
            {
                DB.dbErrorHandlerNoResponse(err);
            }
            resolve(result);
        });
    });
}

const getAllDrivers = async (driver_id)=>
{
    return await new Promise((resolve)=>{
        DB.pool.query('SELECT * FROM public."driver"',[],(err,result)=>{
            if(err)
            {
                DB.dbErrorHandlerNoResponse(err);
            }
            resolve(result);
        });
    });
}

const getRepeatingRoute = async (occurrence) =>
{
    return await new Promise((resolve)=>{
        DB.pool.query('SELECT * FROM route."repeating_route" WHERE "occurrence"=($1)',[occurrence],(err,result)=>{
            if(err)
            {
                DB.dbErrorHandlerNoResponse(err);
            }
            resolve(result);
        });
    });
}

const getRepeatingLocations = async (route_id) =>
{
    return await new Promise((resolve)=>{
        DB.pool.query('SELECT * FROM route."repeating_location" WHERE "route_id"=($1)',[route_id],(err,result)=>{
            if(err)
            {
                DB.dbErrorHandlerNoResponse(err);
            }
            resolve(result);
        });
    });
}

const getDriverCenterPoint = async (driver_id)=>
{
    return await new Promise((resolve)=>{
        DB.pool.query('SELECT * FROM route."center_point" WHERE "driver_id"=($1)',[driver_id],(err,result)=>{
            if(err)
            {
                DB.dbErrorHandlerNoResponse(err);
            }
           // console.log(result);
            resolve(result);
        });
    });
}

const updateTimeLastAssignedRepeatingRoute = async (route_id) =>
{
    return await new Promise((resolve)=>{
        DB.pool.query('UPDATE route."repeating_route" SET "last_assigned"=($1) WHERE "repeating_route_id"=($2)',[new Date(new Date+'GMT').toISOString().slice(0,19).replace(/T/g," "),route_id],(err,result)=>{
            if(err)
            {
                DB.dbErrorHandlerNoResponse(err);
            }
           // console.log(result);
            resolve(result);
        });
    });
}

const addAbnormality = async (abnormality)=>
{
    return await new Promise((resolve)=>{
        DB.pool.query('INSERT INTO public."abnormality"("driver_id","abnormality_code","description","driver_description","datetime","latitude","longitude")VALUES($1,$2,$3,$4,$5,$6,$7)',
        [abnormality.driver_id,abnormality.code,abnormality.description,abnormality.driver_description,abnormality.timestamp,abnormality.latitude,abnormality.longitude],(insertErr,insertRes)=>{
            if(insertErr)
            {
                DB.dbErrorHandlerNoResponse(insertErr);
            }
            resolve();
        });
    });
}

module.exports = {addRoute,getCenterPoints,getTodaysRoutes,getDriver,addRepeatingRoute,addAbnormality,getAllDrivers,
    updateTimeLastAssignedRepeatingRoute,getRepeatingRoute,getRepeatingLocations,getDriverCenterPoint};
