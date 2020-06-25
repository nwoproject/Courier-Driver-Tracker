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
3.  [Manager Endpoints](#manager-endpoints)  
        3.1     [Create Manager](#create-manager)  
        3.2     [Authenticate Manager](#authenticate-manager)  
4.  [Location Endpoints](#location-endpoints)  
        4.1     [Set Location](#set-location)  
        4.2     [Get Location](#get-location)  

# Endpoint Summary

## Driver Endpoint Summary

| Method | Path | Usage |
|---------|-----------------------------------------|------------------|
| `POST` | `/api/drivers` | Create new driver/employee | 
| `POST` | `/api/drivers/authenticate` | Authenticates driver |
| `PUT` | `/api/drivers/:driverid/password` | Create new driver/employee |

## Manager Endpoint Summary

| Method | Path | Usage |
|---------|-----------------------------------------|------------------|
| `POST` | `/api/managers` | Create new manager | 
| `POST` | `/api/managers/authenticate` | Authenticates manager |

## Location Endpoint Summary

| Method | Path | Usage |
|---------|-----------------------------------------|------------------|
| `PUT` | `/api/location/:driverid` | Sets driver's current location | 
| `GET` | `/api/location/driver` | Get location of a driver |

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
| `401` | Invalid token | 
| `404` | Invalid :driverid |
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
}
```

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `200` | Authentication successful |
| `401` | Incorrect email or password | 
| `404` | Manager does not exist |
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
}
```

##### Response Body

This request returns no body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `204` | Location has been updated |
| `401` | Invalid token | 
| `404` | Invalid :driverid |
| `500` | Server error |

## Get Location

Returns the current location of a specified driver.

##### Http Request

`GET /api/location/driver`

##### Request Body

```json
{
    "name": "John",
    "surname": "Doe",
    "id": 1,
}
```
>**NOTE:** One parameter in the request body can be left out, meaning atleast two should be present except if `id` is included, then both `name` and `surname` can be omitted. The API will preferably search by `id` but if it is not present it will use `name` and `surname` to determine which driver location should be returned. ALL MATCHING RECORDS WILL BE RETURNED. Meaning if two drivers share the same name and surname and no `id` was provided then two locations will be returned.

##### Response Body

```json
{
    "id": 1,
    "name": "John",
    "surname": "Doe",
    "latitude": "31.16506",
    "longitude": "-168.64513",
}
```
>**NOTE:** An array can be returned here if a driver happens too share the same name and surname and no `id` was provided in the request body.

##### Response status codes

| Status Code | Description |
|-------------|-------------|
| `200` | Requested driver location retrieved |
| `400` | Bad request (invalid format) | 
| `404` | Driver was not found |
| `500` | Server error |
