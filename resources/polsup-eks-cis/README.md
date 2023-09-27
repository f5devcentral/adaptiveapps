[![license](https://img.shields.io/github/license/f5devcentral/adaptiveapps)](../../LICENSE)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

# PolicySupervisor with F5 BIG-IP AWAF & AWS EKS

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

---

## Solution Description

This solution details the brief deployment steps to replicate the cloud component using the reference example of
AWS Marketplace BIG-IP AWAF integrated into AWS EKS leveraging BIG-IP CIS in a ModernApplication deployment framework, as seen
in the diagram below, to demonstrate a WAF2WAAP migration leveraging PolicySupervisor.

<center><img src=images/polsup-awaf.png width="768"></center>

This solution makes use of [`OWASP Juice Shop`](https://owasp.org/www-project-juice-shop/) in a refactor of the previous
[Multi-Cluster Application Residence](https://github.com/f5devcentral/adaptiveapps/blob/main/resources/f5xc-vk8s-mk8s-nlb/README.md)
for deployment of PolicySupervisor WAF2WAAP conversion workflow.

---

## Requirements

To support this opinionated deployment pattern the following tools, components and credentials are required:

- [Terraform CLI](https://www.terraform.io/docs/cli-index.html)
- [git](https://git-scm.com/)
- [AWS CLI](https://aws.amazon.com/cli/) access.
- [AWS Access Credentials](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)
- [Kubernetes CLi Tools](https://kubernetes.io/docs/reference/kubectl/)
- [F5 PolicySupervisor Account](https://policysupervisor.io/)

___

## Installation

This section details the brief deployment steps to replicate the cloud component using the reference examples of
[F5 AWS Marketplace BIG-IP AMI with AWAF](https://aws.amazon.com/marketplace/seller-profile?id=74d946f0-fa54-4d9f-99e8-ff3bd8eb2745)
& [Container Ingress Services (CIS)](https://clouddocs.f5.com/containers/latest/) integrated with
[AWS EKS](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html) hosting [OWASP JuiceShop](https://owasp.org/www-project-juice-shop/)
ModernApplication, MicroServices, deployment as to demonstrate a PolicySupervisor WAF2WAAP migration conversion workflow.

### Minimum IAM Policy

> **Note**: The policy resource is set as `*` to allow all resources, this is not a recommended practice.

You can find the policy [here](min-iam-policy.json)

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

2. Initialise terraform, to download and prepare the required modules:

    ```sh
    cd $HOME/resources/polsup-eks-cis
    terraform init --upgrade
    ```

3. Validate `TFVARS` and configuration and deployment:

    ```sh
    terraform validate
    ```

4. Plan the deployment on successful validation:

    ```sh
    terraform plan --var-file=$HOME/aws-secrets.tfvars
    ```

5. Finally, apply Terraform plan with auto-approve to avoid the `[y]` confirmation request:

    ```sh
    terraform apply --auto-approve --var-file=$HOME/aws-secrets.tfvars
    ```

___

## Configuration

This section details the steps that can be replicated with CI/CD Pipelines;

### Configure `kubectl` and Origin JuiceShop cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

6. Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    ```sh
    aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>
    ```

7. List all the worker nodes by running the command below

    ```sh
    kubectl get nodes
    ```

8. List all the pods running in `kube-system` namespace

    ```sh
    kubectl get pods -n kube-system
    ```

9. Connect & update BIG-IP admin password to change from the deployment, `Default12345!`, password;

    ```sh
    ssh -i ~/.ssh/id_rsa admin@<bigip-mgmt-address>
    tmsh modify auth password admin <admin_password>
    ```

10. Create `cispartion` to be used for BIG-IP CIS Controller;

    ```sh
    tmsh create auth partition cispartition
    tmsh save sys config
    exit
    ```

11. Add CIS/k8s secret credentials;

    ```sh
    kubectl create secret generic f5-bigip-ctlr-login -n kube-system --from-literal=username=admin --from-literal=password=<admin_password>
    ```

12. Deploy RBAC for CIS/k8s with ServiceAccount;

    ```sh
    kubectl create -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/master/docs/config_examples/rbac/clusterrole.yaml
    ```

### `bigip-ctl-cis` Deployment Preparation

13. Update AS3 deployment manifest `src/k8s-manifests/cis/polsup/polsup-as3` to reflect the *selfIP* of the BIG-IP Virtual Server;

    - Replace `"virtualAddresses": ["{$selfIP}"],` with the VS IP. For single NIC, this is the self IP address.

14. Update `src/k8s-manifests/cis/polsup/cis-deployment.yaml` to reflect the Public ManagementIP of the BIG-IP;

    - Replace `"--bigip-url=https://{$mgmtPublicIP}:8443"` with the ManagementIP. For single NIC, this is the self IP address.

### Deploy JuiceShop Demo & BIG-IP CIS configuration definitions

15. Deploy OWASP JuiceShop Application;

    ```sh
    kubectl apply -f ../../k8s-manifests/cis/polsup/juiceshop-eks.yaml
    ```

16. Deploy & update BIG-IP CIS;

Create and deploy BIG-IP Container Ingress Service and application pods with `as3` definition;

    ```sh
    kubectl create -f ../../k8s-manifests/cis/polsup/cis-deployment.yaml
    sleep 10;
    kubectl create -f ../../k8s-manifests/cis/polsup/polsup-as3.yaml
    ```

___

## Configuration

The following *Inputs* are `defaults` that may be superseded when `TFVARS` files are provided for the provisioning of the supporting infrastructure;

### Terraform Configuration Inputs

| Name | Description | Type | Default             | Required |
|------|-------------|------|---------------------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Deployment Application | `string` | `"OWASP JuiceShop"` |    no    |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of cluster - used by Terratest for e2e test automation | `string` | `"polsup-cis"`      |    no    |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | The Version of Kubernetes to deploy | `string` | `"1.25"`            |    no    |
| <a name="input_ec2_key"></a> [ec2\_key](#input\_ec2\_key) | EC2 Deployment Keypair | `string` | `"ec2_key"`         |   yes    |
| <a name="input_f5_password"></a> [f5\_password](#input\_f5\_password) | BIG-IP Password or Secret ARN (value should be ARN of secret when aws\_secretmanager\_auth = true, ex. arn:aws:secretsmanager:us-west-2:1234:secret:bigip-secret-abcd) | `string` | `"Default12345!"`   |    no    |
| <a name="input_f5_username"></a> [f5\_username](#input\_f5\_username) | User name for the BIG-IP (Note: currently not used. Defaults to 'admin' based on AMI | `string` | `"admin"`           |    no    |
| <a name="input_instance"></a> [instance](#input\_instance) | Deployment EC2 instance type | `string` | `"t3.xlarge"`       |    no    |
| <a name="input_name"></a> [name](#input\_name) | Name prefix of deployment | `string` | `"polsup-cis"`      |    no    |
| <a name="input_owner"></a> [owner](#input\_owner) | Deployment owner | `string` | `"f5-aatt"`         |    no    |
| <a name="input_region"></a> [region](#input\_region) | Name of AWS deployment region | `string` | `"ap-southeast-2"`  |    no    |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR of deployment VPC | `string` | `"10.0.0.0/16"`     |    no    |

### Terraform Deployment Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | EKS cluster ID |
| <a name="output_f5vm01_mgmt_pip_url"></a> [f5vm01\_mgmt\_pip\_url](#output\_f5vm01\_mgmt\_pip\_url) | f5vm01 management public URL |
| <a name="output_f5vm01_mgmt_private_ip"></a> [f5vm01\_mgmt\_private\_ip](#output\_f5vm01\_mgmt\_private\_ip) | f5vm01 management private IP address |
| <a name="output_f5vm01_mgmt_public_ip"></a> [f5vm01\_mgmt\_public\_ip](#output\_f5vm01\_mgmt\_public\_ip) | f5vm01 management public IP address |
| <a name="output_jumpbox_public_dns"></a> [jumpbox\_public\_dns](#output\_jumpbox\_public\_dns) | Public DNS address of Jumpbox |
| <a name="output_region"></a> [region](#output\_region) | AWS region |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | VPC CIDR |
| <a name="output_vpc_management_subnet_cidr"></a> [vpc\_management\_subnet\_cidr](#output\_vpc\_management\_subnet\_cidr) | VPC Management subnet CIDR |
| <a name="output_vpc_private_subnet_cidr"></a> [vpc\_private\_subnet\_cidr](#output\_vpc\_private\_subnet\_cidr) | VPC private subnet CIDR |
| <a name="output_vpc_public_subnet_cidr"></a> [vpc\_public\_subnet\_cidr](#output\_vpc\_public\_subnet\_cidr) | VPC public subnet CIDR |

___

## Decommission

It is recommended to decommission this deployment to both not incur additional costs or consume resources. The correct
workflow to achieve this is to:

- Microservices (Juice Shop) Application Rollback
- F5 BIG-IP CIS removal
- AWS & BIG-IP Infrastructure Rollback.

The steps to achieve this are outlined in the following sections

### *Microservices (Juice Shop) Application Rollback*

1. delete the microservices deployment;

    ```sh
    kubectl delete -f ../../k8s-manifests/cis/polsup/juiceshop-eks.yaml
    ```

2. Rollback & remove BIG-IP Container Ingress Services and application pods with `as3` definition;

    ```sh
    kubectl delete -f ../../k8s-manifests/cis/polsup/polsup-as3.yaml
    sleep 10;
    kubectl delete -f ../../k8s-manifests/cis/polsup/cis-deployment.yaml
    ```

3. To confirm deployment deletion,

    ```sh
    kubectl get pods -o=wide -n=default
    ```

### *F5 BIG-IP and AWS EKS Infrastructure Rollback*

4. change directory to F5 BIG-IP AWAF & AWS EKS deployment:

    ```sh
    cd $HOME/resources/polsup-eks-cis
    ```

5. initialise terraform with previous build `TFVARS`:

    ```sh
    terraform init --upgrade
    ```

6. clean up the environment, destroy the Terraform deployment, the Kubernetes Add-ons, EKS cluster with Node
groups and VPC:

    ```sh
    terraform destroy --auto-approve --var-file=$HOME/aws-secrets.tfvars`
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
