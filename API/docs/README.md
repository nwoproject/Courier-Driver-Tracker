# API documentation

Main API for the courier_driver_tracker system. All requests to the API should contain a valid Bearer token in the header of the request. If no token is present or an invalid token is sent then the request will automatically be rejected.

The following header field should be present in each request: `Authorization: Bearer <token>`.

>**NOTE:** This document is incomplete and will be updated throughout development.

# Table of Contents
1.  [Endpoint Summary](#endpoint-summary)  
2.  [Driver Endpoints](#driver-endpoints)  
		2.1		[Create Driver](#create-driver)  
        2.2     [Authenticate Driver](#authenticate-driver)  
        2.3     [Update Driver Password](#update-driver-password)  
        2.4     [Delete Driver](#delete-driver)  
        2.5     [Reset driver password](#reset-driver-password)  
3.  [Manager Endpoints](#manager-endpoints)  
        3.1     [Create Manager](#create-manager)  
        3.2     [Authenticate Manager](#authenticate-manager)  
        3.3     [Update Passsword](#update-password)
4.  [Location Endpoints](#location-endpoints)  
        4.1     [Set Location](#set-location)  
        4.2     [Get Location](#get-location)  
5.  [Route Endpoints](#route-endpoints)  
        5.1     [Create Route](#create-route)  
        5.2     [Get Driver Route (uncalculated)](#get-driver-route-(uncalculated))  
6.  [Google Maps](#google-maps)  
        6.1     [Search place and get coordinates](#search-place-and-get-coordinates)  
        6.2     [Calculate route](#calculate-route)  
7.  [Abnormality Endpoints](#abnormality-ednpoints)  
        7.1     [Log driver abnormality](#log-driver-abnormality)  
        7.2     [Get all driver abnormalities](#get-all-driver-abnormalities)  

# Endpoint Summary

## Driver Endpoint Summary

| Method | Path | Usage |
|---------|-----------------------------------------|------------------|
| `POST` | `/api/drivers` | Create new driver | 
| `POST` | `/api/drivers/authenticate` | Authenticates driver |
| `PUT` | `/api/drivers/:driverid/password` | Updates the driver's password |
| `DELETE`| `/api/drivers/:driverid`| Deletes a driver and deallocates their assigned routes |
| `PUT` | `/api/drivers/forgotpassword` | Resets password and provides a temporary one via email |

## Manager Endpoint Summary

| Method | Path | Usage |
|---------|-----------------------------------------|------------------|
| `POST` | `/api/managers` | Create new manager | 
| `POST` | `/api/managers/authenticate` | Authenticates manager |
| `PUT` | `/api/managers/:managerid/password` | Updates the manager's password | 

## Location Endpoint Summary

| Method | Path | Usage |
|---------|-----------------------------------------|------------------|
| `PUT` | `/api/location/:driverid` | Sets driver's current location | 
| `GET` | `/api/location/driver` | Get location of a driver |

## Route Endpoint Summary

| Method | Path | Usage |
|---------|-----------------------------------------|------------------|
| `POST` | `/api/routes` | Creates a new delivery route | 
| `GET` | `/api/routes/:driverid` | Returns a driver's active delivery routes |

## Google Maps Endpoint Summary

| Method | Path | Usage |
|---------|-----------------------------------------|------------------|
| `GET` | `/api/google-maps/web` | Returns location details with a nice picture |
| `POST` | `/api/google-maps/navigation` | Uses the google maps api to calculate a delivery route |

## Driver Abnormalities Endpoint Summary

| Method | Path | Usage |
|---------|-----------------------------------------|------------------|
| `POST` | `/api/abnormalities/:driverid` | Logs a new abnormality for a specific driver |
| `GET` | `/api/abnormalities/:driverid` | Gets all abnormality entries of a specific driver |

# Driver Endpoints

## Create Driver

Creates a new driver, this endpoint will only be used by managers. A driver cannot add himself to the system.

##### Http Request

`POST /api/drivers`

##### Request Body

```json
{
    "email": "example@example.com",
    "name": "John",
    "surname": "Doe"
}
```
##### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `201` | Driver created and email containing one time use password sent to driver |
| `400` | Invalid email | 
| `409` | Email already in use |
| `500` | Server error |

## Authenticate Driver

Authenticates driver, mainly for session management purposes.

##### Http Request

`POST /api/drivers/authenticate`

##### Request Body

```json
{
    "email": "example@example.com",
    "password": "5RqwKzK1A7Tcacd1JvF5lM0963qFbxMw",
}
```
##### Response Body

```json
{
    "id": 1,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "name": "John",
    "surname": "Doe"
}
```

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `200` | Authentication successful |
| `401` | Incorrect email or password | 
| `404` | Driver does not exist |
| `500` | Server error |

## Update Driver Password

Used to update driver password

##### Http Request

`PUT /api/drivers/:driverid/password`

##### Request Body

```json
{
    "password": "5RqwKzK1A7Tcacd1JvF5lM0963qFbxMw",
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw"
}
```
##### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `204` | Password has been updated | 
| `404` | Invalid :driverid or token|
| `500` | Server error |

## Delete Driver

Removes a driver from the database, this will permanently delete all the drivers data from the database and deallocate repeating routes that the driver was assinged to.

##### Http Request

`DELETE /api/drivers/:driverid`

##### Request Body

```json
{
    "id" : 1,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "manager": true
}
```
>**NOTE:** The example shown above is the case where a manager wishes to delete a driver, thus a manager id and token is expected for authorization purposes. If the request is made from the app from a driver wishing to remove himself from the system (this feature might be removed in the future, meaning only a manager will only ever be able to delete a driver) then the id in the request body can be omitted since the driver id is passed in as a request parameter. The value of manager however should then be set to false.

##### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `200` | Driver successfully deleted | 
| `400` | Missing or empty parameters in the request body |
| `401` | Invalid manager id or token |
| `404` | Driver with that driver id doesn't exist |
| `500` | Server error | 

## Reset driver password

This requests resets the drivers password to a temporary password that is 8 characters long and generated randomly. The password consisting of random characters is then sent to the driver via email. The driver can then use that password to log in to the app and update their password.

##### Http Request

`PUT /api/drivers/forgotpassword`

##### Request Body

```json
{
    "email": "example@example.com"
}
```

##### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `204` | Driver password reset and an email was sent | 
| `404` | Driver with that email address does not exist |
| `500` | Server error | 

# Manager Endpoints

## Create Manager

Creates a manager account.

##### Http Request

`POST /api/managers`

##### Request Body

```json
{
    "email": "example@example.com",
    "password": "5RqwKzK1A7Tcacd1JvF5lM0963qFbxMw",
    "name": "John",
    "surname": "Doe"
}
```

##### Response Body

```json
{
    "id": 1,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
}
```

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `201` | Manager created |
| `400` | Invalid email |
| `409` | Email already in use | 
| `500` | Server error |

## Authenticate Manager

Authenticates a manager.

##### Http Request

`POST /api/managers/authenticate`

##### Request Body

```json
{
    "email": "example@example.com",
    "password": "5RqwKzK1A7Tcacd1JvF5lM0963qFbxMw",
}
```

##### Response Body

```json
{
    "id": 1,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "name": "John",
    "surname": "Doe"
}
```

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `200` | Authentication successful |
| `401` | Incorrect email or password | 
| `404` | Manager does not exist |
| `500` | Server error |

## Update Passsword

Used to update a manager's password

##### Http Request

`PUT /api/managers/:managerid/password`

##### Request Body

```json
{
    "password": "5RqwKzK1A7Tcacd1JvF5lM0963qFbxMw",
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw"
}
```
##### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `204` | Password has been updated | 
| `404` | Invalid :managerid or token|
| `500` | Server error |

# Location Endpoints

## Set Location

Updates the drivers current location.

##### Http Request

`PUT /api/location/:driverid`

##### Request Body

```json
{
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "latitude": "-25.7542559",
    "longitude": "28.2321043"
}
```

##### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `204` | Location has been updated |
| `401` | Invalid :driverid or token|
| `500` | Server error |

## Get Location

Returns the current location of a specified driver.

##### Http Request

`GET /api/location/driver`

##### Request Body

No request body, however the following parameters is expected in the query string.

| Parameter | Example |
|-------------|-------------|
| `id` | ID of courier driver |
| `name` | Name of driver |
| `surname` | Driver's surname |

Example usage: `/api/location/driver?name=John&surname=Doe`;

>**NOTE:** One parameter in the request can be left out, meaning atleast two should be present except if `id` is included, then both `name` and `surname` can be omitted. The API will preferably search by `id` but if it is not present it will use `name` and `surname` to determine which driver location should be returned. ALL MATCHING RECORDS WILL BE RETURNED. Meaning if two drivers share the same name and surname and no `id` was provided then two drivers will be returned.

##### Response Body

```json
{
    "drivers": [
        {
            "id": 1,
            "name": "John",
            "surname": "Doe",
            "latitude": "-25.7542559",
            "longitude": "28.2321043"
        }
    ]
}
```
>**NOTE:** An array of drivers will always be returned, even if searched by `id`.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `200` | Requested driver location retrieved |
| `400` | Bad request (invalid format) | 
| `404` | Driver was not found |
| `500` | Server error |

# Route Endpoints

## Create Route

Creates a new delivery route from the passed in parameters and assignes it to a specific driver. The endpoint expects a `route` array that contains the coordinates of each delivery address that forms part of the route that the driver must take. The manager's session `token` as well as their `id` should be present in the request body.

##### Http Request

`POST /api/routes`

##### Request Body

```json
{
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "id": 1,
    "driver_id" : 1,
    "route" : [
        {
            "latitude" : "-25.7542559", 
            "longitude": "28.2321043"
        },
        {
            "latitude" : "-25.7674421",
            "longitude": "28.1991501"
        }
    ]
}
```
##### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `201` | Route successfully created |
| `400` | Bad request (invalid format or missing parameters) | 
| `401` | Manager token and id does not match |
| `404` | Invalid driver_id |
| `500` | Server error |

## Get Driver Route (Uncalculated)

Returns all active routes currently assgined to a specific driver. It will return an array of routes that each contain an array of locations consisting of coordinates. Each location is an address that the driver must make a delivery to on his route.

##### Http Request

`GET /api/routes/:driverid`

##### Request Body

This request has no body.

##### Response Body

```json
{
    "driver_id": 1,
    "active_routes: ": [
        {
            "route_id": 1,
            "locations": [
                {
                    "latitude": "-25.7542559",
                    "longitude": "28.2321043"
                },
                {
                    "latitude": "-25.7674421",
                    "longitude": "28.1991501"
                }
            ]
        }
    ]
}
```
##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `200` | Driver's active routes successfully retrieved |
| `404` | Driver not found or currently has no active routes | 
| `500` | Server error |

## Google Maps

## Search place and get coordinates

Takes in a string parameter which is then used to search for a specific location using the google maps API. Multiple candidates can be returned, the returned results contains all the important information about a location like the coordinates, street address and a link to a photo of the location. If no photo was found for a candidate, then the photo field of the candidate will simply contain `404`.

##### Http Request

`GET /api/google-maps/web`

##### Request Body

No request body, however the following parameters is expected in the query string.

| Parameter | Description |
|-------------|-------------|
| `searchQeury` | Location to be seached for |

Example usage: `/api/google-maps/web?searchQeury=university+of+pretoria`


##### Response Body

```json
{
    "candidates": [
        {
            "formatted_address": "Lynnwood Rd, Hatfield, Pretoria, 0002, South Africa",
            "geometry": {
                "location": {
                    "lat": -25.7545492,
                    "lng": 28.2314476
                },
                "viewport": {
                    "northeast": {
                        "lat": -25.74999825,
                        "lng": 28.24116345
                    },
                    "southwest": {
                        "lat": -25.75869965,
                        "lng": 28.22178205
                    }
                }
            },
            "name": "University of Pretoria",
            "place_id": "ChIJ0zuFF71hlR4RAslCW-07CKc",
            "photo": "https://lh3.googleusercontent.com/p/AF1QipM_W8dIy7pl7emNnT3PGh0xINyh8-jNoYeoLeGG=s1600-w400"
        }
    ],
    "status": "OK"
}
```
##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `200` | Location found and details returned |
| `404` | No location was found |
| `500` | Server error |

## Calculate Route

The calculate route endpoint does just that, it calculates the route that the driver should take when making deliveries. This endpoint takes the coordinates of each delivery address that forms part of the route as well as the starting point (warehouse) from the database and sends the data through to the `google maps api` in order to calculate the most optimum route as well as get directions for the driver to follow. The requested route data is then sent back in the response body as one big json object. This json object can be thousands of lines long, so an example can not be given here, instead a short example can be seen [here](https://github.com/COS301-SE-2020/Courier-Driver-Tracker/blob/feature/navigation/courier_driver_tracker/assets/json/route.json).

##### Http Request

`POST api/google-maps/navigation`

##### Request Body

```json
{   
    "id": 1,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "route_id": 1
}
```

##### Response Body

[Short example](https://github.com/COS301-SE-2020/Courier-Driver-Tracker/blob/feature/navigation/courier_driver_tracker/assets/json/route.json)

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `200` | Route successully caclulated and returned |
| `204` | Route found but no delivery addresses were assigned to it, no response body returned |
| `400` | Bad request. (Missing or invalid parameters in body) |
| `401` | Unauthorized |
| `404` | Route with that route_id not found |
| `500` | Server error |
| `501` | Route could not be calculated |

## Abnormality Endpoints

## Log driver abnormality

This endpoint is used to store any driver abnormalities in the database so that it can later be used to train the AI as well as generate driver reports. Each abnormality has a specific code assigned to it to make it easy to differentiate between diffrent types of abnormalities.

| Abnormality Code | Description |
|-------------|-------------|
| `100` | Standing still for too long. |
| `101` | Driver came to a sudden stop. | 
| `102` | Driver exceeded the speed limit.|
| `103` | Driver took a diffrent route than what was prescribed. |
| `104` | Driver was driving with the company car when no deliveries were scheduled. |

##### Http Request

`POST /api/abnormalities/:driverid`

##### Request Body

```json
 {   
    "code": 101,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "description": "Tree jumped in to the middle of the road, tried to avoid it but ended up crashing in to it",
    "latitude": "-25.7",
    "longitude": "28.7",
    "timestamp": "2020-08-11 09:00:00"
 }
```
##### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `201` | Abnormality was successfully logged |
| `400` | Bad request (missing parameters in request body) | 
| `401` | Invalid :driverid and token combination |
| `500` | Server error |

## Get all driver abnormalities

This endpoint returns all abnormalities that were logged of a specific driver.

##### Http Request

`GET /api/abnormalities/:driverid`

##### Request Body

This request expects no body.

##### Response Body

```json
{
    "driver_id": 1,
    "abnormalities": {
        "code_100": {
            "code_description": "Standing still for too long.",
            "driver_abnormalities": []
        },
        "code_101": {
            "code_description": "Driver came to a sudden stop.",
            "driver_abnormalities": [
                {
                    "driver_description": "Tree jumped in to the middle of the road, tried to avoid it but ended up crashing in to it",
                    "latitude": "-25.7",
                    "longitude": "28.7",
                    "timestamp": "2020-08-11 09:00:00"
                }
            ]
        },
        "code_102": {
            "code_description": "Driver exceeded the speed limit.",
            "driver_abnormalities": []
        },
        "code_103": {
            "code_description": "Driver took a diffrent route than what prescribed.",
            "driver_abnormalities": []
        },
        "code_104": {
            "code_description": "Driver was driving with the company car when no deliveries were scheduled.",
            "driver_abnormalities": []
        }
    }
}
```

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `200` | All logged abnormalities of driver returned |
| `204` | Request executed successfully, but driver either has no logged abnormalities or doesn't exist. No request body returned | 
| `500` | Server error |
