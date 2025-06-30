#!/bin/bash
# Start all microservices and Express Gateway for local development (parallel, foreground)

echo "Starting auth-service on port 3000..."
(cd auth-service && rails server -p 3000) &

echo "Starting backend-service on port 3001..."
(cd backend-service && rails server -p 3001) &

echo "Starting Express Gateway on port 8080..."
(cd app-express-gateway && npm start) &

wait
