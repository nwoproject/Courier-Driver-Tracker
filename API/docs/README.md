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
        2.6     [Create Driver Centerpoint](#create-driver-centerpoint)  
        2.7     [Update Driver Centerpoint Radius](#update-driver-centerpoint-radius)  
        2.8     [Update Driver Centerpoint Location](#update-driver-centerpoint-location)  
        2.9     [Delete Driver Centerpoint](#delete-driver-centerpoint)  
        2.10    [Get Driver Centerpoint](#get-driver-centerpoint)  
3.  [Manager Endpoints](#manager-endpoints)  
        3.1     [Create Manager](#create-manager)  
        3.2     [Authenticate Manager](#authenticate-manager)  
        3.3     [Update Passsword](#update-password)
4.  [Location Endpoints](#location-endpoints)  
        4.1     [Set Location](#set-location)  
        4.2     [Get Location](#get-location)  
5.  [Route Endpoints](#route-endpoints)  
        5.1     [Create Route](#create-route)  
        5.2     [Create Route (auto-assign)](#create-route-auto-assign)  
        5.3     [Create Repeating Route](#create-repeating-route)
        5.4     [Get Driver Route (uncalculated)](#get-driver-route-uncalculated)  
        5.5     [Timestamp Delivery Location](#timestamp-delivery-location)  
        5.6     [Complete Route](#complete-route)  
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
| `POST` | `/api/drivers/centerpoint` | Creates a new centerpoint and assigns a driver to it |
| `PUT` | `/api/drivers/centerpoint/radius` | Updates the centerpoint's radius to a new value |
| `PUT` | `/api/drivers/centerpoint/coords` | Changes location of the centerpoint |
| `DELETE` | `/api/drivers/centerpoint/:driverid` | Deletes the centerpoint which the driver was assigned to |
| `POST` | `/api/drivers/centerpoint/:driverid` | Returns the centerpoint which the driver was assigned to |

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
| `POST` | `/api/routes` | Creates a new delivery route and assigns it to specified driver| 
| `POST` | `/api/routes/auto-assign` | Creates a new delivery route and automatically assgins it to a driver |
| `POST` | `/api/routes/repeating` | Creates a new repeating delivery route that happens daily,weekly or monthly |
| `GET` | `/api/routes/:driverid` | Returns a driver's active delivery routes |
| `PUT` | `api/routes/location/:locationid` | Stores a timestamp of when a driver reached a delivery on his route |
| `PUT` | `api/routes/completed/:routeid` | Stores a timestamp of when a route was completed by a driver |

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

Returns the `id` of the driver that was added.

```json
{
    "id": 1,
}
```

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

## Create Driver Centerpoint
a Driver centerpoint simulates a geofence that marks a delivery region which a driver is responsible for. This is used in the automatic assignment of routes to a driver. In order of importance a driver will be assigned a route according to: `Distance between driver centerpoint and the average longitude and latitude of all deliveries (excluding starting point) of a route, the driver's centerpoint radius, the number of routes currently assigned to the driver for a particular day.` a Centerpoint consists of a `radius (in kilometers)`, `latitude` and `longitude`.

##### Http Request

`POST /api/drivers/centerpoint`

#### Request Body

```json
{
    "id" : 1,
    "driver_id": 2,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "latitude": "-25.75405822",
    "longitude": "28.24932575",
    "radius": 20
}
```
#### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `201` | Centerpoint successfully created. | 
| `400` | Bad request (Missing parameters in request body). |
| `401` | Invalid manager id and token combination. |
| `404` | No driver with that driver_id exists. |
| `409` | Driver is allready assigned to a centerpoint. |
| `500` | Server error. | 

## Update Driver Centerpoint Radius

This request updates the centerpoint's radius to the new value passed in the request body. The radius is measured as distance in kilometers.

##### Http Request

`PUT /api/drivers/centerpoint/radius`

#### Request Body

```json
{
    "id" : 1,
    "driver_id": 2,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "radius": 15
}
```
#### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `204` | Centerpoint's radius successfully updated | 
| `400` | Bad request (Missing parameters in request body). |
| `401` | Invalid manager id and token combination. |
| `404` | No centerpoint assigned to that driver exists. |
| `500` | Server error. | 

## Update Driver Centerpoint Location

This request takes in a new latitude and longitude value to change the region of the centerpoint.

##### Http Request

`PUT /api/drivers/centerpoint/coords`

#### Request Body

```json
{
    "id" : 1,
    "driver_id": 2,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "latitude": "-25.75405822",
    "longitude": "28.24932575"
}
```
#### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `204` | Centerpoint's coordinates successfully updated | 
| `400` | Bad request (Missing parameters in request body). |
| `401` | Invalid manager id and token combination. |
| `404` | No centerpoint assigned to that driver exists. |
| `500` | Server error. | 

## Delete Driver Centerpoint

Deletes a centerpoint assigned to a driver.

##### Http Request

`DELETE api/drivers/centerpoint/:driverid`

#### Request Body

```json
{
    "id" : 1,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
}
```
#### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `200` | Centerpoint successfully deleted. | 
| `400` | Bad request (Missing parameters in request body). |
| `401` | Invalid manager id and token combination. |
| `404` | No centerpoint assigned to that driver exists. |
| `500` | Server error. | 

## Get Driver Centerpoint

Returns the centerpoint currently assgined to the driver.

##### Http Request

`POST api/drivers/centerpoint/:driverid`

#### Request Body

```json
{
    "id" : 1,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
}
```

#### Response Body

```json
{
    "driver_id": 2,
    "name": "John",
    "surname": "Doe",
    "centerpoint": {
        "latitude": "-25.75405822",
        "longitude": "28.24932575",
        "radius": "25km"
    }
}
```
##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `200` | Centerpoint assigned to driver successfully retrieved | 
| `400` | Bad request (Missing parameters in request body). |
| `401` | Invalid manager id and token combination. |
| `404` | No centerpoint assigned to that driver exists. |
| `500` | Server error. | 

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

Creates a new non-daily delivery route from the passed in parameters and assignes it to a specific driver. The endpoint expects a `route` array that contains the coordinates of each delivery address that forms part of the route that the driver must take. The manager's session `token` as well as their `id` should be present in the request body.

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
            "latitude" : "-25.74740981", 
            "longitude": "28.23001385",
            "address": "Lynnwood Rd, Hatfield, Pretoria, 0002, South Africa",
            "name": "University of Pretoria"
        },
        {
            "latitude" : "-25.75815531",
            "longitude": "28.2270956",
            "address": "George Storrar Dr &, Leyds St, Groenkloof, Pretoria, 0027",
            "name": "University of Pretoria - Groenkloof Campus"
        },
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

## Create Route (auto-assign)

Creates a new non-daily delivery route from the passed in parameters and tries to automatically assign it to a driver using the driver's centerpoint (region driver is responsible for). It first calculates the average latitude and longitude of the passed in route (excluding starting point) to get an average location. It then calculates the distance of each driver's centerpoint from the average location of the route. The drivers are then ranked from the best candidate to the worst candidate according to that distance. The api then attempts to assign the route starting from the best candidate. If the route is outside the best candidate's radius or if the best candidate currently has another route assigned to them then the api will move on to the next candidate and repeat the process. The request will return the `id`,`name` and `surname` of the candidate the route was assigned to. If the route can't be assigned to any candidate then a status code of `204` is returned and the route should be manually assigned by a manager.

##### Http Request

`POST api/routes/auto-assign`

##### Request Body

```json
{
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "id": 1,
    "route" : [
        {
            "latitude" : "-25.74740981", 
            "longitude": "28.23001385",
            "address": "Lynnwood Rd, Hatfield, Pretoria, 0002, South Africa",
            "name": "University of Pretoria"
        },
        {
            "latitude" : "-25.75815531",
            "longitude": "28.2270956",
            "address": "George Storrar Dr &, Leyds St, Groenkloof, Pretoria, 0027",
            "name": "University of Pretoria - Groenkloof Campus"
        },
    ]
}
```
##### Response Body

```json
{
    "driver_id": 1,
    "name": "John",
    "surname": "Doe"
}
```
##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `201` | Route successfully created and assigned to driver |
| `204` | Route could not be automatically assigned to a driver |
| `400` | Bad request (invalid format or missing parameters) | 
| `401` | Unauthorized (incorrect manager id and token combination). |
| `500` | Server error |
| `501` | No driver center points, route could not be created |

## Create Repeating Route

Creates a new delivery route that repeats daily, weekly or monthly. Repeating routes are automatically assigned to drivers everyday at the start of the day. When assigning routes preference will be given to drivers with centerpoints, thereafter routes will be randomly assigned between the available drivers with no centerpoint.
>**NOTE:** The `occurrence` parameter in the request body should only contain the value `daily`,`weekly` or `monthly` any other value will end the request and return a status code of `400`.

##### Http Request

`POST /api/routes/repeating`

##### Request Body

```json
{
    "id": 1,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "occurrence": "daily",
    "route" : [
        {
            "latitude" : "-25.74740981", 
            "longitude": "28.23001385",
            "address": "Lynnwood Rd, Hatfield, Pretoria, 0002, South Africa",
            "name": "University of Pretoria"
        },
        {
            "latitude" : "-25.75815531",
            "longitude": "28.2270956",
            "address": "George Storrar Dr &, Leyds St, Groenkloof, Pretoria, 0027",
            "name": "University of Pretoria - Groenkloof Campus"
        },
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
| `401` | Unauthorized (incorrect manager id and token combination). |
| `500` | Server error |

## Get Driver Route (uncalculated)

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
                    "location_id": 1,
                    "latitude": "-25.7542559",
                    "longitude": "28.2321043",
                    "address": "Lynnwood Rd, Hatfield, Pretoria, 0002, South Africa",
                    "name": "University of Pretoria"
                },
                {
                    "location_id": 2,
                    "latitude": "-25.7674421",
                    "longitude": "28.1991501",
                    "address": "George Storrar Dr &, Leyds St, Groenkloof, Pretoria, 0027",
                    "name": "University of Pretoria - Groenkloof Campus"
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

## Timestamp Delivery Location

Stores a timestamp of when a driver reached a specfic location/delivery that formed part of their route.

##### Http Request

`PUT api/routes/location/:locationid`

##### Request Body

```json
 {   
    "id": 1,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "timestamp": "2020-08-15 09:00:00"
 }
```

### Response body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `204` | Timestamp successfully stored. |
| `400` | Bad request (missing parameters in request body). | 
| `401` | Unauthorized (incorrect id and token combination). |
| `404` | Location with that :locationid does not exist. |
| `500` | Server error |

## Complete Route

Marks the route that was assigned to the driver as complete and stores the completion date and time as a timestamp. This endpoint will also check that each delivery address (henceforth referred to as location) that formed part of the route has a timestamp associated with it which would indicate that the driver did indeed visit each location that formed part of his route. (The actual path he took is not checked, the endpoint only checks if the driver visted each location of the route to make sure he could of actually made all the deliveries regardless of the path the took).

##### Http Request

`PUT api/routes/completed/:routeid`

##### Request Body

```json
 {   
    "id": 1,
    "token": "37q9juQljxhHno8OWpr0fDqIRQJmkBgw",
    "timestamp": "2020-08-15 12:00:00"
 }
```

### Response body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `204` | Route successfully marked as completed and timestamp stored. |
| `206` | Route marked as complete but one or more locations that formed part of the route was never visited by the driver. |
| `400` | Bad request (missing parameters in request body). | 
| `401` | Unauthorized (incorrect id and token combination). |
| `404` | There is no route with that :routeid assigned to the driver. |
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
