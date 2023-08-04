[![license](https://img.shields.io/github/license/f5devcentral/adaptiveapps)](../../LICENSE)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

# Malware & AntiVirus F5XC 

## Table of Contents

<details>
<summary>Click to expand.</summary>

- [Solution Description](#solution_description)
- [Value](#value)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Decommission](#decommission)
- [TODO](#todo)
- [Contributing](#contributing)
- [License](#license)
- [Credits](#credits)

</details>


---
## Solution Description

This solution details the brief deployment steps to replicate the cloud component using the reference example of 
F5 Distributed Cloud (XC) Managed K8s (mK8s) deployment, as seen in the diagram above, in demonstration of ICAP & 
Malware services at the CustomerEdge.  This code can be seen reflected with the high-level diagram below:

<img src=images/macif.png width="1050" class="center">


---
## Requirements

To support this opinionated deployment pattern the following tools, components and credentials are required:

* [Terraform CLI](https://www.terraform.io/docs/cli-index.html)
* [git](https://git-scm.com/)
* [F5XC API Credentials](https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials)
* [AWS CLI](https://aws.amazon.com/cli/) access.
* [AWS Access Credentials](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)
* [OpenSSL Toolkit](https://www.openssl.org/source/)


---
## Installation 

### **Distributed ICAP & Malware services**

This section details the brief deployment steps to replicate the cloud component using the reference example of 
F5 Distributed Cloud (XC) Virtual K8s (vK8s) deployment within the CustomerEdge (CE), as seen in the diagram above, 
in demonstration of distributed ICAP & Malware services.

> #### *__Prerequisite__*
>
> ***NOTE:*** *For the use of this solution the following command to extract .p12 certificate to an individual certificate 
> and private key for the F5XC Tenancy:*
> ```shell
> openssl pkcs12 -info -legacy -in \<tenant\>.console.ves.volterra.io.api-creds.p12 -out certificate.cert -nokeys
> openssl pkcs12 -info -legacy -in \<tenant\>.console.ves.volterra.io.api-creds.p12 -out private_key.key -nodes -nocerts
> ```

This solution makes use of [`clamav`](https://github.com/Cisco-Talos/clamav) in a refactor of the previous 
[Multi-Cluster Application Residence](https://github.com/f5devcentral/adaptiveapps/blob/main/resources/f5xc-vk8s-mk8s-nlb/README.md)
for deployment of ICAP/Malware AntiVirus Distributed deployment solution.

#### *__Tasks__*:

1. First, provision environment variables for `terraform` as outlined in the 
[documentation](https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/terraform), _e.g._;

```sh
export VOLT_API_P12_FILE=$HOME/file/location/api_cred.p12
export VOLT_API_URL=https://<tenant>.console.ves.volterra.io/api
export VES_P12_PASSWORD="Sup3rS3cr3tSqu1rr3l?!"
```

> **_Note:_** 
> *Variables need to be set for deployment, modifications can be made to the `variables.tf` file, creation of 
> `override.tf` or use of a [tfvars file](https://www.terraform.io/language/values/variables#variable-definitions-tfvars-files) 
> or [TF_VAR_ environment variables](https://www.terraform.io/cli/config/environment-variables#tf_var_name).  
> Throughout this deployment solution it will use local `auto.example.tfvars` variable files.*

2. Next, create `TFVARS` file for deployment as per example, updating both `base` and `app_fqdn` for Domain delegation, 
_e.g_;

```json
// API Creds
api_url = "https://<tenant>.console.ves.volterra.io/api"
api_p12_file = "<tenant>.console.ves.volterra.io.api-creds.p12"
// Base Name for deployment
base_tag = "icap-ce"
```

> **_Note:_** 
> *This deploys to the US F5XC Region, please refer to 
> [F5 Distributed Cloud Site](https://docs.cloud.f5.com/docs/ves-concepts/site) for more details on deployed edges 
> and regions.*

3. Clone the [AdaptiveApps](https://github.com/f5devcentral/adaptiveapps) repository.

```sh
> cd $HOME
> git clone https://github.com/f5devcentral/adaptiveapps.git
```

4. Copy the F5 DistributedCloud API p12 bundle file into the `files/` path;

```sh
> cp api_cred.p12 $HOME/resources/terraform/files
```

5. Prepare the OpenSSL Certificate and Private Key for usage with F5XC Site registration;

```sh
cd $HOME/resources/terraform/f5xc-aws-icap/files
openssl pkcs12 -info -legacy -in \<tenant\>.console.ves.volterra.io.api-creds.p12 -out certificate.cert -nokeys
openssl pkcs12 -info -legacy -in \<tenant\>.console.ves.volterra.io.api-creds.p12 -out private_key.key -nodes -nocerts
```

6. Initialise terraform, to download and prepared modules:

```sh
cd $HOME/resources/terraform/
terraform init --upgrade
```
  
7. Validate `TFVARS` and configuration and deployment:

```sh
terraform validate
```

8. Plan the deployment on successful validation:

```sh
terraform plan --var-file=$HOME/auto.example.tfavrs
```

9. Finally, apply Terraform plan with auto-approve to avoid the `[y]` confirmation request:

```sh
terraform apply --auto-approve --var-file=$HOME/terraform.tfvars
```

___
## Configuration

This section details the steps that can be replicated with CI/CD Pipelines;

10. using downloaded `kubeconfig` to deploy ClamAV application stack to namespace;

```shell
kubectl apply -f $HOME/resources/k8s-manifests/f5xc-icap/ClamAVConfigMap.yaml --kubeconfig /path/to/downloaded/kubeconfig.yaml
```



> *NOTE:*
> As per the associated demo video, to replicate the port forwarding;
> ```shell
> kubectl port-forward cra-deployment-<pod-instance> 3000:3000 --kubeconfig /path/to/ves_system_f5xc-icap_kubeconfig_global.yaml
> ```  
---
## Decommission

It is recommended to decommission this deployment to both not incur additional costs or consume resources. The correct 
workflow to achieve this is to:

* Microservices (ICAP) Application Rollback
* F5XC Virtual Kubernetes Rollback

The steps to achieve this are outlined in the following sections


### *Microservices (ICAP) Application Rollback* 

1. change path to manifest file;
```shell
cd resource/k8s-manifests/f5xc-aws-icap/
```

2. delete the microservices deployment;
```shell
kubectl delete -f manifest.yaml --kubeconfig /path/to/downloaded/kubeconfig.yaml
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

3. change directory to F5XC icap deployment:
    - `cd $HOME/resources/terraform/f5xc-aws-icap`
   
4. initialise terraform with previous build `TFVARS`:
    - `terraform init --upgrade`
   
7. destroy plan:
    - `terraform destroy --auto-approve --var-file=$HOME/f5xc_icap.tfvars`



---
## Support

The contents of this repository are meant to serve as examples and are not covered by F5 support.
If you come across a bug or other issue when using these recipes, please open a GitHub issue to help our team keep track 
of content that needs improvement.
Note, the code in this repository is community supported and is not supported by F5 Inc.  For a complete list of 
supported projects please reference [SUPPORT.md](../../../SUPPORT.md).


---
## Community Code of Conduct

Please refer to the [F5 DevCentral Community Code of Conduct](../../../code_of_conduct.md).


---
## License

The contents of this repository are made available under two license.
All documentation, specifically any Markdown files, is licensed under 
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode).
Everything else is licensed under [Apache 2.0](../../../LICENSE).


---
## Copyright

Copyright 2014-2022 F5 Networks Inc.


----
## Contributing

See [the contributing file](../../../CONTRIBUTING.md)!


---
## Credits