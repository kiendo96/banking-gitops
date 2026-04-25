# Jenkins CI/CD Context

## Overview
Jenkins orchestrates the build and deployment process. It runs inside Kubernetes and uses dynamic pod templates (defined in `banking-source/vars/agentFactory.groovy`) to spin up build agents.

## Core Pipelines & Configurations
- **Standard Pipeline:** The main workflow is defined in `banking-source/vars/standardPipeline.groovy`.
- **Credentials:**
  - `harbor-credentials`: Used by Kaniko to push images to Harbor.
  - `github-credentials`: Used by the Git agent to push manifest updates to `banking-gitops`.
  - *Note:* These credentials must be injected into Jenkins from Vault via ExternalSecrets. Do not create them manually in the Jenkins UI if avoidable.

## Deployment Workflow
- Changes to `values-dev.yaml` or `Makefile` in this directory must be generated using `make generate ENV=dev` before committing to Git.
