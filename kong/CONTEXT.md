# Kong API Gateway Context

## Overview
Kong acts as the primary API Gateway and Ingress Controller for the entire Kubernetes cluster.

## Architecture
- **Gateway API:** Kong is configured to use the modern Kubernetes Gateway API (`gatewayAPI.enabled: true` and `GatewayAlpha=true`) instead of traditional Ingress resources.
- **Routing:** Services (like Harbor and the banking microservices) define `HTTPRoute` resources to route external traffic through Kong.
- **Proxy:** Kong is exposed externally via a `LoadBalancer` service.

## Configuration Updates
- When making routing changes, prefer updating or creating `HTTPRoute` resources in the respective service's overlay directory (e.g., `banking-gitops/apps/<service>/kustomize/overlays/dev/`) rather than altering Kong's core values.
