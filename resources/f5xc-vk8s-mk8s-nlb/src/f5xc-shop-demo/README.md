# F5XC Demo Shop Example


[![license](https://img.shields.io/github/license/merps/f5-ts-sumo)](LICENSE)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

This document serves as an amendment to documented deployment of the refactored BoutiqueShop Microservers Google demo.

## Table of Contents

<!--TOC-->

- [Security](#security)
- [Background](#background)
- [Prerequisites](#prerequisites)
- [F5 Distributed Cloud Configuration(s)](#f5-distributed-cloud-configurations)
    - [API Certificate](#api-certificate)
- [Installation](#installation)
    - [AWS](#aws)
    - [F5XC](#f5xc)
- [Configuration](#configuration)
- [Usage](#usage)
- [API](#api)
- [Contributing](#contributing)
- [License](#license)

<!--TOC-->

## Background

This work was undertaken to demonstrate mutli-cluster, initially, to replicate Virtual Kubernetes (k8s) resilancy leveraging F5 Distributed Cloud (F5XC)

This configuration outline currently only supports the deployment pattern as detailed in the diagram below,

<center><img src=images/config-diagram-autoscale-ltm.png width="400"></center>

## Prerequisites

To support this deployment pattern the following components are required:

* F5 BIP-IP (physical or VE)
* F5 Toolchain Components:
    * [F5 Application Services v3 (AS3)](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/)
    * [F5 Telemetry Streaming (TS)](https://clouddocs.f5.com/products/extensions/f5-telemetry-streaming/latest/)
* [Terraform CLI](https://www.terraform.io/docs/cli-index.html)
* [git](https://git-scm.com/)
* [AWS CLI](https://aws.amazon.com/cli/) access.
* [AWS Access Credentials](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)


## F5 Distributed Cloud Configuration(s)

This demo workload deployment requires the use of [API Certificate](https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials) for the use of deployment.

For simplicity, steps replicate this deployment are as follows;

***a)***    First, clone the repo:
```
git clone https://gitswarm.f5net.com/adaptive-application-tiger-team/adaptive-applications-kitchen.git
```

***b)***    Second, create a [tfvars](https://www.terraform.io/docs/configuration/variables.html) file in the following format to deploy the environment;

#### Inputs

| Name           | Description                                         | Type   | Default    | Required |
|----------------|-----------------------------------------------------|--------|------------|----------|
| api_url        | F5XC Tenant Console                                 | String | *NA*       | **Yes**  |
| api_p12_file   | F5XC API Certificate                                | String | *NA*       | **Yes**  |
| base           | F5XC Tenant Namespace                               | String | *NA*       | **Yes**  |
| app_fqdn       | Fully Qualified Domain Name (FQDN)                  | String | *NA*       | **Yes**  |
| registry_server| Container Registry Server                           | String | *NA*       | **Yes**  |
| registry_config_json| Kubenetes Registry Information                 | String | *NA*       | **Yes**  |


***c)*** Create and export variables for credentials and secret keys.

* Create this variable and assign it your API credentials password: `export VES_P12_PASSWORD=<credential password>`

* Create this variable and assign it the path to the API credential file previously created and downloaded from Console: `export VOLT_API_P12_FILE=<path to your local p12 file>`

* Create this variable and assign it the URL for your tenant. For example: `export VOLT_API_URL=https://f5-big-ip.console.ves.volterra.io/api

* Create this variable and assign it your AWS secret key that has been encoded with Base64: `export TF_VAR_b64_aws_secret_key=<base64 encoded value>`

* Create this variable and assign it your AWS access key: export `TF_VAR_aws_access_key=<access key>`

***d)***    Forth, intialise and plan the terraform deployment as follows:
```
cd k8s-usecase/src/terraform/f5xc-environment/f5xc-shop-demo
terraform init
terraform plan --vars-file ../terraform.tfvars
```

this will produce and display the deployment plan using the previously created `variables.tfvars` file.


***e)***    Then finally to deploy the successful plan;
```
terraform apply --vars-file ../terraform.tfvars
```

> **_NOTE:_**  It is recommended to perform a `terraform destroy` to not incur excessive usage costs outside of free tier.


This deployment also covers the provisioning of the additional F5 prerequeset components so required for deployment example covered in the [F5XC Shop Demo](https://github.com/f5devcentral/f5xc-shop-demo)



## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.7.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.8.0 |
| <a name="requirement_volterra"></a> [volterra](#requirement\_volterra) | 0.11.14 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_f5xc"></a> [f5xc](#module\_f5xc) | ./module/f5xc | n/a |
| <a name="module_vk8s-app"></a> [vk8s-app](#module\_vk8s-app) | ./module/vk8s-app | n/a |
| <a name="module_vk8s-utility"></a> [vk8s-utility](#module\_vk8s-utility) | ./module/vk8s-utility | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_p12_file"></a> [api\_p12\_file](#input\_api\_p12\_file) | n/a | `string` | `"./creds/tenant.api-creds.p12"` | no |
| <a name="input_api_url"></a> [api\_url](#input\_api\_url) | n/a | `string` | `"https://tenant.ves.volterra.io/api"` | no |
| <a name="input_app_fqdn"></a> [app\_fqdn](#input\_app\_fqdn) | n/a | `string` | `"demo-app.tenant.example.com"` | no |
| <a name="input_base"></a> [base](#input\_base) | n/a | `string` | `"demo-app"` | no |
| <a name="input_bot_defense_region"></a> [bot\_defense\_region](#input\_bot\_defense\_region) | n/a | `string` | `"US"` | no |
| <a name="input_cred_expiry_days"></a> [cred\_expiry\_days](#input\_cred\_expiry\_days) | n/a | `number` | `89` | no |
| <a name="input_enable_bot_defense"></a> [enable\_bot\_defense](#input\_enable\_bot\_defense) | n/a | `bool` | `false` | no |
| <a name="input_enable_client_side_defense"></a> [enable\_client\_side\_defense](#input\_enable\_client\_side\_defense) | n/a | `bool` | `false` | no |
| <a name="input_enable_synthetic_monitors"></a> [enable\_synthetic\_monitors](#input\_enable\_synthetic\_monitors) | n/a | `bool` | `false` | no |
| <a name="input_hub_site_selector"></a> [hub\_site\_selector](#input\_hub\_site\_selector) | n/a | `list` | <pre>[<br>  "ves.io/siteName in (ves-io-dc12-ash)"<br>]</pre> | no |
| <a name="input_registry_config_json"></a> [registry\_config\_json](#input\_registry\_config\_json) | registry config data string in type kubernetes.io/dockerconfigjson | `string` | `"b64 encoded json"` | no |
| <a name="input_registry_server"></a> [registry\_server](#input\_registry\_server) | n/a | `string` | `"some_registry.example.com"` | no |
| <a name="input_spoke_site_selector"></a> [spoke\_site\_selector](#input\_spoke\_site\_selector) | n/a | `list` | <pre>[<br>  "ves.io/siteName in (ves-io-ny8-nyc, ves-io-wes-sea)"<br>]</pre> | no |
| <a name="input_utility_site_selector"></a> [utility\_site\_selector](#input\_utility\_site\_selector) | n/a | `list` | <pre>[<br>  "ves.io/siteName in (ves-io-dc12-ash)"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_url"></a> [app\_url](#output\_app\_url) | FQDN VIP to access the web app |
