# Multi-Cluster Kubernetes Workload Migration and Failover Resiliency

[![license](https://img.shields.io/github/license/:f5devcentral/:adaptiveapps)](LICENSE)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

## Table of Contents

- [Background](#background)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
    - [AWS EKS](#aws-eks)
    - [F5XC vK8s](#f5xc-vk8s)
- [Configuration](#configuration)
  - [AWS EKS](#eks)
  - [F5XC mK8S](#mk8s)
- [Decommission](#decommission)
  - [AWS](#aws)
  - [F5XC](#f5xc)
- [TODO](#todo)
- [Contributing](#contributing)
- [License](#license)
- [Credits](#credits)
---

## Background

As our customers’ successful business outcomes more and more rely on successful application deployments, the ability to reduce time-to-market while increasing application resilience and availability has become paramount. Kubernetes usage has become mainstream, along with adoption of automation-enabling APIs. 

Gone are the days when customers would deploy their monolithic applications to a single on-prem data center. With the advent of microservices, virtual machines, containers, and private / public cloud, our customer deployments have evolved into a much more complicated state involving a hybrid of many of these technologies. While deployments may have become more complicated and, ironically, automated, application resiliency and availability is still the most important business-focused requirement. 

Customers require the ability to deploy on-prem workloads with F5 application services, with an automated way to migrate these to private / public cloud and/or F5 Distributed Cloud (F5XC) in order to provide a seamless end-user failover experience in case of system unavailability. End users should not be aware nor impacted by any level of application outage. Correspondingly, the business should not be impacted by such outages either in terms of revenue generation, customer-facing services and support, etc.

This work is an opinionated design to demonstrate, with the use of F5 products & tools, Multi-Cluster Kubernetes Workload Migration and Failover Resiliency.

It details the deployment & migrate steps hybrid cloud (cloud/on-prem) K8S workload to Public cloud and/or F5XC to enable transparent failover;

* Ensure the business & end-users are not impacted in case of system or application failure
* This is a quick, as-built, docco for fill out to demonstrate the managed k8s use-case/fail over.

The example deployment pattern as per design is detailed in the follow diagram:
<center><img src=images/vk8s-use-case.png width="768"></center>

---
## Prerequisites

To support this opinionated deployment pattern the following tools, components and credentials are required:

* [Terraform CLI](https://www.terraform.io/docs/cli-index.html)
* [git](https://git-scm.com/)
* [AWS CLI](https://aws.amazon.com/cli/) access.
* [AWS Access Credentials](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)
* [F5XC API Credentials](https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials)
* [FQDN for Domain Delegation](https://docs.cloud.f5.com/docs/how-to/app-networking/domain-delegation)

>#### *__Note__*
> *To proceed with the deployment of the solution the nominated FQDN domain or sub domain must be configure as per [Application Domain Delegation](https://docs.cloud.f5.com/docs/how-to/app-networking/domain-delegation)*
---
## Installation 

This section outlines the deployment of both AWS example [EKS architecture](https://aws-ia.github.io/terraform-aws-eks-blueprints/v4.20.0/) alongside F5XC [vK8S deployment](https://docs.cloud.f5.com/docs/how-to/app-management/vk8s-deployment) 
in the aid of demonstrating cluster namespace residency leveraging [Google's microservices cloud-first application](https://github.com/GoogleCloudPlatform/microservices-demo)

### *AWS EKS*

This section details the brief deployment steps to replicate the cloud component using the AWS EKS Deployment blueprints, as seen in the diagram above, in demostration of k8s namespace resilency.  

More thorough and in-depth understandings of the different deployment examples for AWS EKS is well documented at [EKS architecture](https://aws-ia.github.io/terraform-aws-eks-blueprints/v4.20.0/).

#### *__Tasks__*:

1. Go home:

```shell
cd $HOME
```

2. Clone the AWS EKS Deployment repo;

```shell
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

3. configure `AWS_PROFILE` environment variables, `aws_access_key_id` & `aws_secret_access_key` in `$HOME/.aws/credentials`, for commandline access.

4. change path to `examples/` directory;

```shell
cd $HOME/terraform-aws-eks-blueprints/examples/eks-cluster-with-new-vpc
```

5. Initialise terraform, to download and prepared modules:

```sh
terraform init
```
  
6. Validate `TFVARS` and configuration and deployment:

```sh
terraform validate
```

7. Plan the deployment on successful validation, to see deployment steps:

```sh
terraform plan
```

8. apply Terraform plan with auto-approve:

```sh
terraform apply --auto-approve
```

9. as per the Terraform output, update the local `.kubeconfig` with AWS EKS.

```shell
aws eks --region us-east-1 update-kubeconfig --name <cluster_name>
``` 

10. go home, again:

```shell
cd $HOME
```

10. Clond the GCP microservices-demo 

```shell
git clone https://github.com/GoogleCloudPlatform/microservices-demo
```

11. change path for the OnlineShop manifest

```shell
cd microservices-demo/release
```

12. then an application deployment using `kubectl` that will deploy the shop,

```shell
kubectl apply -f kubernetes-manifests.yaml
```

13. to confirm deployment,

```shell
kubectl get pods -o=wide -n=default
```
    
14. Access the web frontend in a browser using the frontend's `EXTERNAL_IP`;
```shell
kubectl get service frontend-external | awk '{print $4}'
```
    
#### *__Deployment Video__*

This is also covered briefly in the following video, [AWS EKS Deployment.](images/k8s-usecase-vid01.mkv)

### *F5XC vK8s*

This section details the brief deployment steps to replicate the cloud component using the a reference example of F5 Distributed Cloud (XC) Virtual K8s (vK8s) deployment, as seen in the diagram above, in demostration of k8s namespace resilency.  

>#### *__Prerequisite__*
> *To proceed with the deployment of the solution the nominated FQDN domain or sub domain must be configure as per [Application Domain Delegation](https://docs.cloud.f5.com/docs/how-to/app-networking/domain-delegation)*

This solution makes use of [`f5xc-shop-demo`](https://github.com/f5devcentral/f5xc-shop-demo)
repo found on [F5DevCentral](https://github.com/f5devcentral/).<sup>[1](#refone)</sup>  This work is refactor of [Google's microservices cloud-first application](https://github.com/GoogleCloudPlatform/microservices-demo).

#### *__Tasks__*:

1. First, provision environment variables for `terraform` as outlined  in the [documention](https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/terraform),
_e.g._;
```sh
export VOLT_API_P12_FILE=$HOME/file/location/api_cred.p12
export VOLT_API_URL=https://(tenant).console.ves.volterra.io/api
export VES_P12_PASSWORD="SuperSecret"
```

> **_Variables_**  *need to be set for deployment, modifications can be made to the `variables.tf` file, creatation of `override.tf` or use of a [tfvars file](https://www.terraform.io/language/values/variables#variable-definitions-tfvars-files) or [TF_VAR_ environment variables](https://www.terraform.io/cli/config/environment-variables#tf_var_name).  Throughout this deployment solution it will use local `<name>.tfvars` variable files.*

2. Next, create `TFVARS` file for deployment as per example, updating both `base` and `app_fqdn` for Domain delegation, _e.g_;

```json
// API Creds
api_url = "https://[tenant].console.ves.volterra.io/api"
api_p12_file = "api_cred.p12"

// Deployment variables
base = "example.com"
app_fqdn = "shop.example.com"

// Registry Server Info
registry_server = "some.registry.example"
registry_config_json = "base64.json"

// Bot Defense Enabled
enable_bot_defense = true
enable_synthetic_monitors = true
enable_client_side_defense = true
```

> **_Note:_** *This deploys to the US F5XC Region, please refer to [F5 Distributed Cloud Site](https://docs.cloud.f5.com/docs/ves-concepts/site) for more details on deployed edges and regions.*

3. Change directory to F5XC shop deployment:

```sh
cd $HOME/src/f5xc-shop-demo/
```

4. Initialise terraform, to download and prepared modules:

```sh
terraform init
```
  
5. Validate `TFVARS` and configuration and deployment:

```sh
terraform validate
```

6. Plan the deployment on successful validation, just to be sure:

```sh
terraform plan --var-file=$HOME/terraform.tfvars
```

7. Finally, apply Terraform plan with auto-approve to avoid the `[y]` confirmation request _(you validated right?)_:

```sh
terraform apply --auto-approve --var-file=$HOME/terraform.tfvars
```

#### *__Deployment Video__*

This is also covered in the following video, [F5XC vK8S deployment.](images/k8s-usecase-vid02.mkv)

---

## Configuration

### F5XC mK8S

In this section we deploy and configure managed kubernetes for F5 distribution cloud,   

1. create a k8s as per [docs](https://docs.cloud.f5.com/docs/how-to/site-management/create-k8s-site)

```shell
> git clone https://gitlab.wirelessravens.org/f5labs/aatt.git
> cd f5labs/aatt/k8s-usecase/src/terraform/aws-environment/aws-f5xc-mk8s
```

2. confirm the token/uuid is the same as the file named `ce_mk8s.yaml`

3. then a kubentes control apply,

```shell
kubectl apply -f ce_mk8s.yaml
```
   
2. create a service discovery policy as per [docs](https://docs.cloud.f5.com/docs/how-to/app-networking/service-discovery-k8s)

3. create an new origin pool using the AWS EKS services discovered, via the console:
    - [origin pool & heath check](https://docs.cloud.f5.com/docs/how-to/app-networking/origin-pools)
   
> *Note: AWS EKS is HTTP and **NOT** HTTPS*

4. finally add the Origin Pool to the existing `shop` [HTTP Application Load Balancer](https://docs.cloud.f5.com/docs/how-to/app-networking/origin-pools)

#### *__Deployment Video__*

This is also covered in the following video, [F5XC mK8S deployment.](images/k8s-usecase-vid03.mkv)

---
## Decommission

It is recommended to decommission this deployment to both not incur additional costs or consume resources. The correct workflow to achieve this is to:

* k8s namespace integration rollback
* mK8S integration deployment rollback
* microservices application deployment rollback
* decommission both;
  * AWS EKS
  * F5XC vK8S

The steps to achieve this are outlined in the following sections

### *Namespace Integration Removal* 

These steps are performed via the F5 Distributed Cloud console:

1. remove the aws eks [origin pool & heath check](https://docs.cloud.f5.com/docs/how-to/app-networking/origin-pools) from Application Load Balancer
2. delete service discovery policy created during installation as per [docs](https://docs.cloud.f5.com/docs/how-to/app-networking/service-discovery-k8s)

### *mK8S Integration Removal*

To remove the Managed Kubernetes AWS EKS integration;

1. Within the F5 Distributed Cloud Decommission EKS clusters from [Other Registrations](https://docs.cloud.f5.com/docs/how-to/site-management/manage-site);
    - Home -> Cloud and Edge Sites -> Manage -> Site Management
   
2. Delete k8s deployment of managed k8s from the command line,
    - change path to the supplied manifest
   
```shell
> cd f5devcentral/adaptive-applications-cookbook/resources/f5xc-aws-mk8s-eks
```

3. Deleting the deployment of mK8s to AWS EKS
    - `kubectl delete -f ce_mk8s.yaml`


### *Microservices Application Rollback* 

1. change path to manifest file;
```shell
cd $HOME/microservices-demo/release
```

2. delete the microservices deployment;
```shell
kubectl delete -f kubernetes-manifests.yaml
``` 

3. to confirm deployment deletion,
    - `kubectl get pods -o=wide -n=default`


#### *F5XC Virtual Kubernetes Rollback (microservices vk8s f5xc)*

The following steps are required to rollback the microservices hosted in F5 DistributedCloud;

1. provision environment vars for `terraform`

```sh
export VOLT_API_P12_FILE=$HOME/file/location/api_cred.p12
export VOLT_API_URL=https://tenant.console.ves.volterra.io/api
export VES_P12_PASSWORD="SuperSecret"
```

3. change directory to F5XC shop deployment:
    - `cd $HOME/f5xc-shop-demo`
   
4. initialise terraform with previous build `TFVARS`:
    - `terraform init --upgrade`
   
7. destroy plan:
    - `terraform destroy --auto-approve --var-file=$HOME/f5xc_shop.tfvars`

---
## TODO

- [ ] pipelines for TF/cli curl.

---
## Contributing

See [the contributing file](CONTRIBUTING.md)!

PRs accepted.

---
## License

[Apache](../LICENSE)

## Credits

<a name="refone">[1]</a> - [Kevin Reynolds](https://github.com/kreynoldsf5)
