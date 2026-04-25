# Cert-Manager Context

## Overview
Cert-Manager is used to automatically provision and manage TLS certificates within the Kubernetes cluster.

## Configuration
- Installed via Helm with CRDs enabled.
- It provides the necessary infrastructure for other services (like Harbor or Kong if TLS is enabled) to dynamically request Let's Encrypt or self-signed certificates.
