# RabbitMQ Message Broker Context

## Overview
RabbitMQ handles asynchronous messaging and event-driven communication between the banking microservices.

## Architecture
- **Deployment Mode:** Runs as a single replica (`replicaCount: 1`).
- **Storage:** Configured with an `emptyDir` volume for the application data in the dev environment.

## Secrets Management
- **Security:** Relies on an `ExternalSecret` that creates `vault-rabbitmq-secret` to inject secure passwords and the Erlang cookie.
- Passwords and cookies are stored and managed centrally in HashiCorp Vault (`secret/rabbitmq`).
