# Simple File Storage

This is an APIs that allows you to upload user files to Four types of file storage S3, DB, Local, or FTP.

## Prerequisites

Before you begin, ensure you have met the following requirements as I have it:
* You have installed Ruby version ruby 3.2.3 (2024-01-18 revision 52bb2ac0a6) [x64-mingw-ucrt]
* You have installed Rails version 7.1.3.2
* You have installed node v20.12.0

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing.

### Cloning the Repository

To clone the repository, run the following command:

```bash
git clone https://github.com/AamerHejazi/simple_storage_api.git
```

### Setting Up the Database

Run the database migrations:

```bash
rails db:migrate
```
### Seed data
Populate the database by running the following:
```bash
rails db:seed
```

### Running the Application
To start the Rails server, run:
```bash
rails server
```
now the base path of the server is ```http://localhost:3000```

### ERD Diagram
You will find it inside the root folder with the file name ```erd.pdf```


### Create an account and Registration

- ```POST '/register'```
to start using the APIs you need to create an account using this API with the following:

you need to send the below fields:
```
{
    "email": "admin5@example.com",
    "password": "admin5",
    "password_confirmation": "admin5"
}
```
This API will return the ID and the email in the response with HTTP code ``` created 201 ``` with the following response

```
{
    "id": "5",
    "email": "admin5@example.com"
}
```

### Create a token 

- ```POST '/login' ```
to start using the APIs you need to create a token using this API with the following:

You need to send the below fields:
```
{
    "email": "admin5@example.com",
    "password": "admin5"
}
```
This API will return the ```id``` and the ```email``` in the response with HTTP code ``` OK 200 ```
with the following response

```
{
    "bearer_token": "92ba8fabbc23060e65ed3ad9089e02242be43643",
    "expires_at": "2024-05-11T05:02:56.214Z"
}
```
Now you can use the token in the headers ```Authorization``` to call other APIs and set the value is ```92ba8fabbc23060e65ed3ad9089e02242be43643```

### Upload blob
- ```POST '/v1/blobs'```

```
{
    "id": "blob_id",
    "data": "base64 data"
}
```
This API will return the ```id```,```data```,```size```, and ```created_at``` in the response with HTTP code ```Created 201``` with the following response

```
{
    "id": "blob_id",
    "data": "base64 data",
    "size": 300,
    "created_at": "2024-04-13T15:19:52.621Z"
}
```


### Download blob
- ```GET '/v1/blobs/{blobId}'```

This API will return the ```id```,```data```,```size```, and ```created_at``` in the response with HTTP code ```OK 200``` with the following response

```
{
    "id": "blob_id",
    "data": "base64 data",
    "size": 300,
    "created_at": "2024-04-13T15:19:52.621Z"
}
```