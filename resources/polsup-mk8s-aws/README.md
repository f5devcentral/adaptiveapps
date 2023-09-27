[![license](https://img.shields.io/github/license/f5devcentral/adaptiveapps)](../../LICENSE)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

# Juice Shop Managed Kubernetes (mk8s) F5 XC

## Table of Contents

<details>
<summary>Click to expand.</summary>

- [Solution Description](#solution_description)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Decommission](#decommission)
- [Contributing](#contributing)
- [License](#license)
- [Credits](#credits)

</details>

---

## Solution Description

This solution details the brief deployment steps to replicate the cloud component using the reference example of
F5 Distributed Cloud (XC) Managed K8s (mK8s) deployment, as seen in the diagram below, in demonstration of WAF2WAAP
migration leveraging PolicySupervisor.

<center><img src=images/polsup-mk8s.png width="768"></center>

---

## Requirements

To support this opinionated deployment pattern the following tools, components and credentials are required:

- [Terraform CLI](https://www.terraform.io/docs/cli-index.html)
- [git](https://git-scm.com/)
- [F5 XC API Credentials](https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials)
- [AWS CLI](https://aws.amazon.com/cli/) access.
- [AWS Access Credentials](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)
- [OpenSSL Toolkit](https://www.openssl.org/source/)

---

## Installation

### **Distributed JuiceShop with F5 Distributed Cloud (XC) IngressController**

This section details the brief deployment steps to replicate the cloud component using the reference example of
F5 Distributed Cloud (XC) Managed K8s (mK8s) deployment within the CustomerEdge (CE) in demonstration of distributed
PolicySupervisor WAF2WAAP migration conversion.

> #### ***Prerequisite***
>
> ***NOTE:*** *For the use of this solution the following command to extract .p12 certificate to an individual certificate
> and private key for the F5 XC Tenancy:*
>
> ```shell
> openssl pkcs12 -info -legacy -in \<tenant\>.console.ves.volterra.io.api-creds.p12 -out certificate.cert -nokeys
> openssl pkcs12 -info -legacy -in \<tenant\>.console.ves.volterra.io.api-creds.p12 -out private_key.key -nodes -nocerts
> ```

This solution makes use of [`OWASP Juice Shop`](https://owasp.org/www-project-juice-shop/) in a refactor of the previous
[Multi-Cluster Application Residence](https://github.com/f5devcentral/adaptiveapps/blob/main/resources/f5xc-vk8s-mk8s-nlb/README.md) for deployment of PolicySupervisor WAF2WAAP conversion workflow.

#### ***Deployment Tasks***

1. First, provision environment variables for `terraform` as outlined in the
[documentation](https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/terraform), *e.g.*;

    ```sh
    export VOLT_API_P12_FILE=$HOME/file/location/api_cred.p12
    export VOLT_API_URL=https://<tenant>.console.ves.volterra.io/api
    export VES_P12_PASSWORD="Sup3rS3cr3tSqu1rr3l?!"
    ```

> ***Note:***
> *Variables need to be set for deployment, modifications can be made to the `variables.tf` file, creation of
> `override.tf` or use of a [tfvars file](https://www.terraform.io/language/values/variables#variable-definitions-tfvars-files)
> or [TF_VAR_ environment variables](https://www.terraform.io/cli/config/environment-variables#tf_var_name).  
> Throughout this deployment solution it will use local `input.auto.tfvars` variable files.*

2. Next, create `TFVARS` file for deployment as per example, updating both `base` and `app_fqdn` for Domain delegation,
*e.g*;

    ```json
    // API Creds
    api_url = "https://<tenant>.console.ves.volterra.io/api"
    api_p12_file = "<tenant>.console.ves.volterra.io.api-creds.p12"
    // Base Name for deployment
    base_tag = "polsup-mk8s-ce"
    ```

3. Create an `<secrets>` tfvars file using the `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY` for AWS deployment account,
also provide the SSH PublicKey for connectivity to the provisioned Bastion/Jumpbox Instance,
*e.g*;

    ```json
    aws_access_key = "<AWS_ACCESS_KEY_ID>"
    aws_secret_key = "<AWS_SECRET_ACCESS_KEY>"
    ssh_public_key = "ssh-rsa <development system public key>"
    ```

> ***Note:***
> *This deploys to the US F5 XC Region, please refer to
> [F5 Distributed Cloud Site](https://docs.cloud.f5.com/docs/ves-concepts/site) for more details on deployed edges
> and regions.*

4. Clone the [AdaptiveApps](https://github.com/f5devcentral/adaptiveapps) repository.

    ```sh
    cd $HOME
    git clone https://github.com/f5devcentral/adaptiveapps.git
    ```

5. Copy the F5 DistributedCloud API p12 bundle file into the `files/` path;

    ```sh
    cp $HOME/Downloads/<tenant>.console.ves.volterra.io.api-creds.p12 $HOME/resources/files
    ```

6. Prepare the OpenSSL Certificate and Private Key for usage with F5 XC Site registration;

    ```sh
    cd $HOME/resources/polsup-mk8s-aws/files
    openssl pkcs12 -info -legacy -in <tenant>.console.ves.volterra.io.api-creds.p12 -out certificate.cert -nokeys
    openssl pkcs12 -info -legacy -in <tenant>.console.ves.volterra.io.api-creds.p12 -out private_key.key -nodes -nocerts
    ```

7. Initialise terraform, to download and prepare the required modules:

    ```sh
    cd $HOME/resources/polsup-mk8s-aws
    terraform init --upgrade
    ```
  
8. Validate `TFVARS` and configuration and deployment:

    ```sh
    terraform validate
    ```

9. Plan the deployment on successful validation:

    ```sh
    terraform plan --var-file=$HOME/<secrets>.tfvars
    ```

10. Finally, apply Terraform plan with auto-approve to avoid the `[y]` confirmation request:

    ```sh
    terraform apply --auto-approve --var-file=$HOME/<secrets>.tfvars
    ```

___

## Configuration

This section details the steps that can be replicated with CI/CD Pipelines with both terraform input and output variables;

11. using downloaded `kubeconfig` to deploy OWASP Juice Shop application stack to namespace;

    ```shell
    kubectl apply -f $HOME/resources/k8s-manifests/juice-shop/juiceshop.yaml --kubeconfig /path/to/downloaded/kubeconfig.yaml
    ```

> *NOTE:*
> As per the associated demo video, to replicate the port forwarding;
>
> ```shell
> kubectl port-forward juice-shop-<pod-instance> 3000:3000 --kubeconfig /path/to/ves_system_juice-shop_kubeconfig_global.yaml
> ```  

The following *Inputs* are `defaults` that may be superseded when `TFVARS` files are provided;

### Terraform Configuration Inputs

| Name                                                                              | Description                                                                                                  | Type     | Default                   | Required |
|-----------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|----------|---------------------------|:--------:|
| <a name="input_api_p12_file"></a> [api\_p12\_file](#input\_api\_p12\_file)        | Tenant API credentials - <https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/apis#authentication> | `string` | n/a                       |   yes    |
| <a name="input_api_url"></a> [api\_url](#input\_api\_url)                         | Tenancy API Endpoint - <https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/apis>                  | `string` | n/a                       |   yes    |
| <a name="input_app"></a> [app](#input\_app)                                       | Deployment Application                                                                                       | `string` | `"JuiceShop"`             |    no    |
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key)  | AWS Access Key. Programmable API access key needed for creating the site                                     | `string` | `"<your aws access key>"` |    no    |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key)  | AWS Secret Access Key. Programmable API secret access key needed for creating the site                       | `string` | `"<your aws secret>"`     |    no    |
| <a name="input_base_tag"></a> [base\_tag](#input\_base\_tag)                      | Name prefix of application deployment                                                                        | `string` | `"juiced-ce-aws"`         |    no    |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)          | Name of cluster - used by Terratest for e2e test automation                                                  | `string` | `"juiced-ce-aws"`         |    no    |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | The Version of Kubernetes to deploy for application infrastructure                                           | `string` | `"1.25"`                  |    no    |
| <a name="input_ec2_key"></a> [ec2\_key](#input\_ec2\_key)                         | EC2 Deployment Keypair                                                                                       | `string` | `"mkennedy@f5"`           |    no    |
| <a name="input_instance"></a> [instance](#input\_instance)                        | Deployment EC2 instance type                                                                                 | `string` | `"t3.xlarge"`             |    no    |
| <a name="input_owner"></a> [owner](#input\_owner)                                 | Deployment owner/business unit for Application Ownership                                                     | `string` | `"f5-aatt"`               |    no    |
| <a name="input_region"></a> [region](#input\_region)                              | Name of AWS deployment region for application infrastructure                                                 | `string` | `"ap-southeast-2"`        |    no    |
| <a name="input_site_disk_size"></a> [site\_disk\_size](#input\_site\_disk\_size)  | Disk size in GiB                                                                                             | `number` | `80`                      |    no    |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key)  | SSH Public Key                                                                                               | `string` | `"<your public key"`      |    no    |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr)                      | CIDR of deployment VPC for application infrastructure                                                        | `string` | `"10.0.0.0/16"`           |    no    |

### Terraform Deployment Outputs

| Name                                                                                                                     | Description                   |
|--------------------------------------------------------------------------------------------------------------------------|-------------------------------|
| <a name="output_bastion_public_dns"></a> [bastion\_public\_dns](#output\_bastion\_public\_dns)                           | Public DNS address of Jumpbox |
| <a name="output_region"></a> [region](#output\_region)                                                                   | AWS region                    |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr)                                                           | VPC CIDR                      |
| <a name="output_vpc_management_subnet_cidr"></a> [vpc\_management\_subnet\_cidr](#output\_vpc\_management\_subnet\_cidr) | VPC Management subnet CIDR    |
| <a name="output_vpc_private_subnet_cidr"></a> [vpc\_private\_subnet\_cidr](#output\_vpc\_private\_subnet\_cidr)          | VPC private subnet CIDR       |
| <a name="output_vpc_public_subnet_cidr"></a> [vpc\_public\_subnet\_cidr](#output\_vpc\_public\_subnet\_cidr)             | VPC public subnet CIDR        |

---

## Decommission

It is recommended to decommission this deployment to both not incur additional costs or consume resources. The correct
workflow to achieve this is to:

- Microservices (Juice Shop) Application Rollback
- F5 XC Managed Kubernetes Rollback

The steps to achieve this are outlined in the following sections

### *Microservices (Juice Shop) Application Rollback*

1. change path to manifest file;

    ```shell
    cd resource/k8s-manifests/juice-shop/
    ```

2. delete the microservices deployment;

    ```shell
    kubectl delete -f juiceshop.yaml --kubeconfig /path/to/downloaded/kubeconfig.yaml
    ```

3. to confirm deployment deletion,

    ```sh
    kubectl get pods -o=wide -n=default
    ```

#### *F5 XC Virtual Kubernetes Rollback (microservices vk8s F5 XC)*

The following steps are required to roll back the microservices hosted in F5 DistributedCloud;

1. provision environment vars for `terraform`

    ```sh
    export VOLT_API_P12_FILE=$HOME/file/location/api_cred.p12
    export VOLT_API_URL=https://<tenant>.console.ves.volterra.io/api
    export VES_P12_PASSWORD="Sup3rS3cr3tSqu1rr3l?!"
    ```

3. change directory to F5 XC Juice Shop deployment:

    ```shell
    cd $HOME/resources/polsup-mk8s-aws
    ```

4. initialise terraform with previous build `TFVARS`:

    ```sh
    terraform init --upgrade
    ```

7. destroy plan:

    ```sh
    terraform destroy --auto-approve --var-file=$HOME/<secrets>.tfvars
    ```

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
