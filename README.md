# Adaptive Applications Cookbook

This repository contains recipes and examples to help F5 customers realize the benefits of adaptive applications.

## What Are Adaptive Applications

Adaptive applications utilize an architectural approach that facilitates rapid and often fully-automated responses to changing conditions—for example, new cyberattacks, updates to security posture, application performance degradations, or conditions across one or more infrastructure environments.
And unlike the current state of many apps today that are labor-intensive to secure, deploy, and manage, adaptive apps are enabled by the collection and analysis of live application and security telemetry, service management policies, advanced analytic techniques such as machine learning, and automation toolchains.

Specifically, adaptive applications allow you to:
1. More rapidly detect and neutralize security threats
2. Improve application performance and resilience
3. Speed deployments of new apps
4. Easily unify policy across on-prem, public cloud, and edge environments


Find out more about adaptive applications on [F5's Website](https://www.f5.com/company/adaptive-applications)

## Solution Inventory

| Solution | Category | Description | Resources |
| -------- | -------- |----------- | --------- |
| [Deploy API to NGINX Management Suite](solutions/deploy-api-to-f5-nginx-management-suite) | Performance | Use a CI/CD pipeline to publish and update API routing and developer documentation | [F5 NGINX Management Suite](resources/f5-nginx-management-suite) |
| [Multi-Cluster Application Resilience](solutions/k8s-mutlicluster-resilency/)| Performance | Leveraging F5 DistributedCloud to provide Kubenetes microservices application resilency | [Deployment Example](resources/f5xc-vk8s-mk8s-nlb/)

## Resource Inventory

| Resource | Description | Used By |
| -------- | ----------- | ------- |
| [F5 NGINX Management Suite](resources/f5-nginx-management-suite) | Terraform and Ansible artifacts to deploy F5 NGINX Management Suite to virtual machines | [Deploy API to NGINX Management Suite](solutions/deploy-api-to-f5-nginx-management-suite) |
| [F5 DistributedCloud & AWS EKS](resources/f5xc-vk8s-mk8s-nlb/) | Deployment instructions and artifcats to demonstrate Kubenetes mutli-cluster resilency | [Multi-Cluster Application Resilience](solutions/k8s-mutlicluster-resilency/) |

## Support

The contents of this repository are meant to serve as examples and are not covered by F5 support.
If you come across a bug or other issue when using these recipes, please open a GitHub issue to help our team keep track of content that needs improvement.
Github Issues should be considered as best effort only and you should not expect to receive the same level of response as provided by F5 Support.

## License

The contents of this repository are made available under two license.
All documentation, specifically any Markdown files, is licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode).
Everything else is licensed under [Apache 2.0](LICENSE).

## Copyright

Copyright 2014-2022 F5 Networks Inc.
