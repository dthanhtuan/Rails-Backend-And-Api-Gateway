# Microservices with Rails Authentication Service, Backend Service, and Express Gateway

## Tech Stack

- **Ruby on Rails**
    - `auth-service`: Authentication microservice issuing JWT tokens (RS256)
    - `backend-service`: Business logic microservice serving protected data
- **Express Gateway**
    - API Gateway built on Node.js and Express
    - Handles routing, JWT verification, and proxying requests to microservices
- **JWT (RS256)**
    - Asymmetric JWT signing with RSA private key in auth-service
    - Public key used by Express Gateway to verify tokens

---

## Architecture Overview
```mermaid
flowchart LR
  Clients["Clients (Browsers, Mobile)"]
  EG["Express Gateway (Port 8080)"]
  Auth["auth-service (Rails, 3000)"]
  Backend["backend-service (Rails, 3001)"]

  Clients --> EG
  EG --> Auth
  EG --> Backend

  EG -.->|Routes /auth/*| Auth
  EG -.->|Routes /api/*| Backend
  EG -.->|Verifies JWT tokens| Backend
```
```text
+-------------+     +----------------+          +------------------+
|   Clients   | <-> | Express Gateway| <------> |  Microservices   |
| (Browsers,  |     |   (Port 8080)  |          |                  |
|   Mobile)   |     | - Routes /auth/* to auth-service (port 3000)         |
+-------------+     | - Routes /api/* to backend-service (port 3001)       |
                    | - Verifies JWT tokens on /api/* routes                |
                    +----------------+------------------+
                                     |                  |
                                     |                  |
                    +----------------+                  +----------------+
                    | auth-service   |                  | backend-service|
                    | (Rails, 3000)  |                  | (Rails, 3001)  |
                    +----------------+                  +----------------+
```

- **Clients** authenticate by calling `/auth/login` on the gateway.
- **Express Gateway** proxies `/auth/*` requests to the `auth-service` without JWT verification.
- After login, clients receive a JWT token signed by `auth-service`.
- Clients include the JWT token in `Authorization: Bearer <token>` header for `/api/*` requests.
- Express Gateway verifies the JWT token using the public key.
- Valid requests are proxied to the `backend-service` which serves protected resources.

---

## Sample Flow

1. **User Login & Token Issuance**  
   Client sends POST request to:  http://localhost:8080/auth/login with form data: `username=alice`
   The `auth-service` validates the user (demo accepts any username) and returns a `JWT token` signed with `RS256`.

2. **Access Protected Resource**  
   Client sends GET request to:  http://localhost:8080/api/data with header:  Authorization: Bearer `<JWT_TOKEN>`

3. Express Gateway verifies the JWT token using the public key. If valid, it proxies the request to `backend-service`, which returns protected data.

3. **Unauthorized Access**  
   If the client omits or sends an invalid JWT token, Express Gateway responds with `401 Unauthorized` without forwarding the request.

---

## How to Run Locally

1. Start **auth-service** on port 3000
```bash
cd auth-service
rails server -p 3000
```
2. Start **backend-service** on port 3001
```bash
cd backend-service
rails server -p 3001
```
3. Start **Express Gateway** on port 8080
```bash
cd my-gateway
npm start
```
4. Use `curl` or Postman to test login and protected API access as described above.
```bash
 curl -X POST http://localhost:8080/auth/login -d "username=alice"
{"token":"eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhbGljZSIsImV4cCI6MTc1MTIwMjUzNn0.R4a2vYWPz85LD0cnNXm5IoEp154g3JLclaLEPG78GZkqDkq4amNCILO74qLhy1HvU1xUyioNVufmxJrtjsfKsVf_LNgNnyzpdREYPiW2uF8--PULHLKfyl2YU41si0m9BEovB_FSkGXcVNA4ASi4w7bYKyJNu5RjK1Mq1wMaqETaqYm68yFjRMwXU9dRo20_Smg8BtLPFeX9pxd2j8V3T1rDLJncaRAHOBuSDXqjEwz_Kp29M7kjaVcHvddEMs5YAiCKO8FYyTPX9R_ZS01UboaeWMGtJD5tQ35eUWz91weQsSKAbdPAzJWvkJl95tYHqLONSruqy_JJYZHt20zyAw"}


curl -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhbGljZSIsImV4cCI6MTc1MTIwMjUzNn0.R4a2vYWPz85LD0cnNXm5IoEp154g3JLclaLEPG78GZkqDkq4amNCILO74qLhy1HvU1xUyioNVufmxJrtjsfKsVf_LNgNnyzpdREYPiW2uF8--PULHLKfyl2YU41si0m9BEovB_FSkGXcVNA4ASi4w7bYKyJNu5RjK1Mq1wMaqETaqYm68yFjRMwXU9dRo20_Smg8BtLPFeX9pxd2j8V3T1rDLJncaRAHOBuSDXqjEwz_Kp29M7kjaVcHvddEMs5YAiCKO8FYyTPX9R_ZS01UboaeWMGtJD5tQ35eUWz91weQsSKAbdPAzJWvkJl95tYHqLONSruqy_JJYZHt20zyAw" http://localhost:8080/api/data
{"message":"This is protected data","time":"2025-06-29T19:09:56.959+07:00"}
```
---

## References

- [Express Gateway Documentation](https://www.express-gateway.io/docs/)
- [JWT Introduction](https://jwt.io/introduction/)
- [Ruby JWT Gem](https://github.com/jwt/ruby-jwt)
- [Microservices with API Gateway Pattern](https://microservices.io/patterns/apigateway.html)
- [Example Microservices with Express Gateway](https://dev.to/naseef012/create-a-microservices-app-with-dockerized-express-api-gateway-1kf9)
---
