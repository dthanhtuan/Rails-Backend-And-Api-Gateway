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
1. Install Foreman:
```bash
  npm install -g foreman
```
2. Run the application using Foreman:
```bash
  foreman start
```
3. Use `curl` or Postman to test login and protected API access as described above.
```bash
 curl -X POST http://localhost:8080/auth/login -d "username=alice"
{"token":"eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhbGljZSIsImV4cCI6MTc1MTMwMDg0OH0.G2wwyYupPK4hXnNlV7D1418QTfGoucJJ5kXdHwX__fIDMEnMp9xGdAVjYVoDspckHtKr9nAWz3ScNt6wwfWguG6_1A0HfJxtRtIHM4a3tEuuAXewxx4dXhb0tc8Cw22gNsaYUkhkvzUjgMC8SQPqUoM-ZjIQ6TH4L1FgHlO_BMcnWfhMcA9fwog-_Ql8T2nQY2aJvCSQJFp0aAAZb03Ppjt9PV6DtAbZ8iDRxnYgBYa_nOU_H8yjFfBbgZrzOrUnMsjg6iKXm7_rEfxq9YgAtp6dDklsr818LrQAThz-y7cxAj6mYsW7Yie_tGaR9VbQOt326MYQrD5wVWLi_J84yw"}


curl -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhbGljZSIsImV4cCI6MTc1MTMwMDg0OH0.G2wwyYupPK4hXnNlV7D1418QTfGoucJJ5kXdHwX__fIDMEnMp9xGdAVjYVoDspckHtKr9nAWz3ScNt6wwfWguG6_1A0HfJxtRtIHM4a3tEuuAXewxx4dXhb0tc8Cw22gNsaYUkhkvzUjgMC8SQPqUoM-ZjIQ6TH4L1FgHlO_BMcnWfhMcA9fwog-_Ql8T2nQY2aJvCSQJFp0aAAZb03Ppjt9PV6DtAbZ8iDRxnYgBYa_nOU_H8yjFfBbgZrzOrUnMsjg6iKXm7_rEfxq9YgAtp6dDklsr818LrQAThz-y7cxAj6mYsW7Yie_tGaR9VbQOt326MYQrD5wVWLi_J84yw" http://localhost:8080/api/data
{"message":"This is protected data","time":"2025-06-29T19:09:56.959+07:00"}

curl -H "Authorization: Bearer INVALID_TOKEN" http://localhost:8080/api/data
Unauthorized
```
---
## Certificate Management

The **public key certificate** used by Express Gateway to verify JWT tokens is generated and provided by the **Authentication Service** (`auth-service`). Specifically:

- The `auth-service` generates an RSA key pair (private and public keys).
- The **private key** is used by the `auth-service` to sign JWT tokens.
- The **public key** (`jwt_public.pem`) is copied from the `auth-service` and placed into the Express Gateway’s `certs` directory (e.g., `./certs/public.pem`).
- Express Gateway uses this public key to verify the authenticity and integrity of JWT tokens on protected routes.

**Important:**  
Keep the private key secure and never expose it outside

## Note on `x-gateway-auth` Header for Securing Backend and Auth Services

To enhance the security of the system and ensure that only requests coming through the Express Gateway reach your backend and authentication services, the gateway adds a custom header `x-gateway-auth` with a secret token to all proxied requests.

- In the Express Gateway configuration (`gateway.config.yml`), the proxy policies for both the `authPipeline` and `backendPipeline` include this header under `pipelines` -> service `policy`:
```yml
headers:
        x-gateway-auth: ${GATEWAY_AUTH_TOKEN}
```
- Both `authService` and `backendService` verify this header before processing requests. This prevents direct access to these services, allowing only gateway-forwarded requests.

- Environment Variable for `x-gateway-auth` Header:
To securely manage the secret token used for the `x-gateway-auth` header between Express Gateway and your backend/auth services, this project uses an environment variable named `GATEWAY_AUTH_TOKEN`.
## References
- [Express Gateway Policies](https://www.express-gateway.io/docs/policies/)
  - [JWT Policy](https://www.express-gateway.io/docs/policies/jwt/)
  - [Proxy Policy](https://www.express-gateway.io/docs/policies/proxy/)
  - [Cors Policy](https://www.express-gateway.io/docs/policies/cors/)
- [Express Gateway Documentation](https://www.express-gateway.io/docs/)
- [JWT Introduction](https://jwt.io/introduction/)
- [Ruby JWT Gem](https://github.com/jwt/ruby-jwt)
- [Microservices with API Gateway Pattern](https://microservices.io/patterns/apigateway.html)
- [Example Microservices with Express Gateway](https://dev.to/naseef012/create-a-microservices-app-with-dockerized-express-api-gateway-1kf9)
---
