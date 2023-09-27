[![license](https://img.shields.io/github/license/f5devcentral/adaptiveapps)](../../LICENSE)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

# PolicySupervisor with NGINX+ AppProtect & AWS Compute (EC2)

___

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

___

## Solution Description

This solution details the brief deployment steps to replicate the cloud component using the reference example of
F5 AWS Marketplace NGINX+ with AppProtect deployed with AWS EC2 in a Traditional deployment framework, as seen
in the diagram below, to demonstrate a WAF2WAAP migration leveraging PolicySupervisor.

<center><img src=images/polsup-nginx.png width="768"></center>

This solution makes use of [`OWASP Juice Shop`](https://owasp.org/www-project-juice-shop/) in a refactor of the previous
[Multi-Cluster Application Residence](https://github.com/f5devcentral/adaptiveapps/blob/main/resources/f5xc-vk8s-mk8s-nlb/README.md)
for deployment of PolicySupervisor WAF2WAAP conversion workflow.

___

## Requirements

To support this opinionated deployment pattern the following tools, components and credentials are required:

- [Terraform CLI](https://www.terraform.io/docs/cli-index.html)
- [git](https://git-scm.com/)
- [AWS CLI](https://aws.amazon.com/cli/) access.
- [AWS Access Credentials](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)
- [F5 PolicySupervisor Account](https://policysupervisor.io/)

___

## Installation

This section details the brief deployment steps to replicate the cloud component using the reference examples of
[F5 AWS Marketplace NGINX+ with AppProtect](https://aws.amazon.com/marketplace/search/results?searchTerms=NGINX&CREATOR=741df81b-dfdc-4d36-b8da-945ea66b522c&filters=CREATOR)
deployed with [AWS EC2](https://aws.amazon.com/ec2/) hosting [OWASP JuiceShop](https://owasp.org/www-project-juice-shop/) in a
Traditional deployment pattern as to demonstrate a PolicySupervisor WAF2WAAP migration conversion workflow.

#### ***Deployment Tasks***

1. Clone the repo using the command below

    ```sh
    git clone https://github.com/f5devcentral/adaptiveapps.git
    ```

> ***Note:***
> *Variables need to be set for deployment, modifications can be made to the `variables.tf` file, creation of
> `override.tf` or use of a [tfvars file](https://www.terraform.io/language/values/variables#variable-definitions-tfvars-files)
> or [TF_VAR_ environment variables](https://www.terraform.io/cli/config/environment-variables#tf_var_name).  
> Throughout this deployment solution it will use local `input.auto.tfvars` variable files.*

2. Initialise terraform, to download and prepare required modules:

    ```sh
    cd $HOME/resources/polsup-aws-nginx
    terraform init --upgrade
    ```

3. Validate `TFVARS` and configuration and deployment:

    ```sh
    terraform validate
    ```

4. Plan the deployment on successful validation:

    ```sh
    terraform plan
    ```

5. Finally, apply Terraform plan with auto-approve to avoid the `[y]` confirmation request:

    ```sh
    terraform apply --auto-approve
    ```

___

## Configuration

The following *Inputs* are `defaults` that may be superseded when `TFVARS` files are provided for the provisioning of the supporting infrastructure;

### Terraform Configuration Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Deployment Application | `string` | `"JuiceShop"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of cluster - used by Terratest for e2e test automation | `string` | `"hack-nap"` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | The Version of Kubernetes to deploy | `string` | `"1.25"` | no |
| <a name="input_ec2_key"></a> [ec2\_key](#input\_ec2\_key) | EC2 Deployment Keypair | `string` | `"<ec2-keypair>"` | yes |
| <a name="input_instance"></a> [instance](#input\_instance) | Deployment EC2 instance type | `string` | `"t3.xlarge"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix of deployment | `string` | `"polsup-nap"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Deployment owner | `string` | `"f5-aatt"` | no |
| <a name="input_region"></a> [region](#input\_region) | Name of AWS deployment region | `string` | `"ap-southeast-2"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR of deployment VPC | `string` | `"10.0.0.0/16"` | no |

### Terraform Deployment Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_private_address"></a> [app\_private\_address](#output\_app\_private\_address) | Public DNS address of Jumpbox |
| <a name="output_jumpbox_public_dns"></a> [jumpbox\_public\_dns](#output\_jumpbox\_public\_dns) | Public DNS address of Jumpbox |
| <a name="output_region"></a> [region](#output\_region) | AWS region |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | VPC CIDR |
| <a name="output_vpc_management_subnet_cidr"></a> [vpc\_management\_subnet\_cidr](#output\_vpc\_management\_subnet\_cidr) | VPC Management subnet CIDR |
| <a name="output_vpc_private_subnet_cidr"></a> [vpc\_private\_subnet\_cidr](#output\_vpc\_private\_subnet\_cidr) | VPC private subnet CIDR |
| <a name="output_vpc_public_subnet_cidr"></a> [vpc\_public\_subnet\_cidr](#output\_vpc\_public\_subnet\_cidr) | VPC public subnet CIDR |

### PolicySupervisor Integration

This section outlines the steps required to;

- connect to bastion system
- PolicySupervisor agent installation/configuration

This workflow may also be replicated with CI/CD Pipelines;

> ***NOTE:***
> ***NAP `agent_install` requires both `root` username and pem file location) as per***
> ***[NGINX Configuration Sharing](https://docs.nginx.com/nginx/admin-guide/high-availability/configuration-sharing/)***

5. ssh to bastion system;

    ```sh
    ssh -i /path/to/ec2-keypair.pem ubuntu@<output.jumpbox_public_dns>
    ```

6. Open browser and login to [PolicySupervisor](https://policysupervisor.io) to generate agent token;

    *a.* Select *Add Provider* from *Providers* left-panel menu

    *b.* From *Provider Type* in *Add Providers* pop-out menu, select *NGINX*

    *c.* Press *+ Add new agent* to generate token required for agent installation, copy this token.

    *d.* Press *Done*

> **NOTE:**
>
> *`root` system account `id_rsa` SSH Private key need to be converted to pem format and outside of `.ssh/`*
> *path as demostrated with the follow commands;*
>
>   ```sh
>   sudo cp /root/.ssh/id_rsa .
>   ssh-keygen -p -f id_rsa -m pem
>   ```

7. Download & install agent on bastion system,

    ```sh
    wget -O agent_install https://gitlab.policysupervisor.io/wafps/agent-install/-/package_files/1160/download 
    chmod a+x agent_install
    sudo ./agent_install
    ```

8. Enter values as prompted from agent install

- Agent Token & agent install name:

    ```sh
    Enter agent token: ************************************
    Enter agent name: polsup-nap
    ```

9. Switch back to browser window to finalise agent connection;

- Choose correct agent from *Select Agent* dropdown menu
- Select the correct secret as installed with agent from *Secret* dropdown menu
- Enter *Provider Name* use for the NGINX connection.
- Enter *Provider SSH* from terraform output.
- press *Test Connection*

10. When connection tests successfully, select *Ingest Configuration*, this will connect to the NGINX instance and download all
policies.

11. Select checkbox for all policies then press *Continue*

12. Press *Next* in *Profiles* pop-out window.

13. Enter a commit message within *Summary* pop-out window, then press *Save & Ingest*

14. Once complete, a *Success!* pop-out window will appear.

The PolicySupervisor Agent is now securely connected & registered to [policysupervisor.io](https://policysupervisor.io/)

___

## Decommission

It is recommended to decommission this deployment to both not incur additional costs or consume resources. The correct
workflow to achieve this is to:

- Traditional (Juice Shop) Application Rollback
- F5 NGINX+ with AppProtect & OWASP JuiceShop Compute
- AWS & NGINX+ Infrastructure Rollback.

The steps to achieve this are outlined in the following sections

### *F5 NGINX+ with NAP and AWS Compute Infrastructure Rollback*

1. change directory to F5 BIG-IP AWAF & AWS EKS deployment:

    ```sh
    cd $HOME/resources/polsup-aws-nginx
    ```

2. initialise terraform with previous build `TFVARS`:

    ```sh
    terraform init --upgrade
    ```

3. clean up the environment, destroy the Terraform deployment, the NGINX+ NAP & OWASP JuiceShop Compute:

    ```sh
    terraform destroy --auto-approve`
    ```

___

## Support

The contents of this repository are meant to serve as examples and are not covered by F5 support.
If you come across a bug or other issue when using these recipes, please open a GitHub issue to help our team keep track
of content that needs improvement.
Note, the code in this repository is community supported and is not supported by F5 Inc.  For a complete list of
supported projects please reference [SUPPORT.md](../../SUPPORT.md).

___

## Community Code of Conduct

Please refer to the [F5 DevCentral Community Code of Conduct](../../code_of_conduct.md).

___

## License

The contents of this repository are made available under two license.
All documentation, specifically any Markdown files, is licensed under
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode).
Everything else is licensed under [Apache 2.0](../../LICENSE).

___

## Copyright

Copyright 2014-2022 F5 Networks Inc.

___

## Contributing

See [the contributing file](../../CONTRIBUTING.md)!

___

## Credits
