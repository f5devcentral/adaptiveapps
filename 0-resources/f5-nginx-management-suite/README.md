# F5 NGINX Management Suite and API Connectivity Manager Infrastructure as Code

## Solution Description
This solution deploys F5 NGINX Management Suite with API Connectivity Manager to OpenStack using Terraform and Ansible.
The installation follows the steps outlined in the [install guide](https://docs.nginx.com/nginx-management-suite/admin-guides/installation/install-guide/).
Since most of the configuration is done with Ansible, this solution should be simple to port to other environments.
Simply modify the `main.tf` Terraform file as needed for your environment.
This solution consists of three compute instances: The Management Suite host, a Data Plane host, and a Developer Portal host.
Additional information on the architecture, including the below diagram, can be found in the [API Connectivity Manager Architecture Overview page](https://docs.nginx.com/nginx-management-suite/acm/about/architecture/)

![Architecture Diagram](https://docs.nginx.com/nginx-management-suite/acm/about/images/HighLevelComponents.png)

## Value
This solution deploys the F5 NGINX Management Suite and API Connectivity Manager using infrastructure as code tools to provide consistent, scalable, and reliable infrastructure.
Ansible playbooks are used extensively to allow users at various stages of adopting infrastructure as code to take advantage of this solution.
Users just getting started with automation can use the playbooks directly to provide some consistency to their environments.
More advanced users can execute these playbooks from Hashicorp Terraform when deploying instances, or even use Hashicorp Packer to generate pre-built images to deploy.
The Developer Portal from Management Suite provides a common location to publish APIs to, and a common location to discovery APIs from.
This can help reduce the time to learn new APIs and reduce the risk of creating duplicate APIs.

## Demo
![Demo Video](images/demo.mp4)

## Automation to Deploy Solution

### Prerequisites
To deploy this solution, you need Terraform and Ansible installed.
Additionally, you will need the [NGINX Ansible role](https://galaxy.ansible.com/nginxinc/nginx) installed.

### Just Add Credentials
Since it would be a bad idea to submit credentials and other secrets to this repository, the following files are excluded and will need to be provided by the user:
* **license/nginx.lic**: This is the NGINX Management Suite license obtained from F5
* **license/nginx-repo.crt**: This is the certificate used to connect to the NGINX repository obtained from F5
* **license/nginx-repo.key**: This is the key used to connect to the NGINX repository obtained from F5
* **ssh.key**: This file is used to connect to the provisioned servers to configure them with Ansible.
This file can be named anything, and the path must be specified in the `private_key_path` Terraform variable
* Any credentials needed for the Terraform provider

### Variables
In addition to any variables required by providers, the following variables are passed from Terraform to Ansible.
Please see the [Terraform documentation](https://developer.hashicorp.com/terraform/language/values/variables#assigning-values-to-root-module-variables) for more information on setting variables.

* **private_key_path**: Path to the private key file that Ansible will use to connect to the hosts.
* **nms_password**: The password that will be used for the admin user in F5 NGINX Management Suite.
* **nms_cluster_name**: This is the name given to the API gateway cluster. The Developer Portal cluster will use the same name suffixed with "-dev".

### Make It so!
Now comes the fun part.
If your variables are specified in a `terraform.tfvars` file, then you just need to initialize Terraform and run the Terraform file.

```bash
terraform init
terraform apply
```

## Deep Dive
The following sections describe how the installation instructions from the [install guide](https://docs.nginx.com/nginx-management-suite/admin-guides/installation/install-guide/) were translated to Ansible tasks.
These playbooks were run on Ubuntu 20.04 instances, but should be modifiable to work with other distributions.

### Install NGINX
```yaml
  - name: Install NGINX Plus
    ansible.builtin.include_role:
      name: nginxinc.nginx
    vars:
      nginx_type: plus
      nginx_license:
        certificate: license/nginx-repo.crt
        key: license/nginx-repo.key
      nginx_remove_license: false
```
We can use the nginxinc.nginx role to install NGINX Plus.
The `nginx_remove_license` property is set to `false` so that we can reuse the license setup for installing Managementt Suite components later.

### Install ClickHouse
```yaml
  - name: Add ClickHouse Key
    ansible.builtin.apt_key:
      keyserver: keyserver.ubuntu.com
      id: E0C56BD4
  - name: Update cache
    ansible.builtin.apt:
      update_cache: true
      cache_valid_time: 3600
  - name: Add ClickHouse Repo
    ansible.builtin.apt_repository:
      repo: deb http://repo.yandex.ru/clickhouse/deb/stable/ main/
  - name: Install ClickHouse
    ansible.builtin.apt:
      pkg:
        - apt-transport-https
        - clickhouse-server
        - clickhouse-client
  - name: Configure Clickhouse default user
    ansible.builtin.copy:
      dest: /etc/clickhouse-server/users.d/10-default.xml
      content: |
        <?xml version="1.0"?>
        <clickhouse>
            <users>
                <default>
                    <password>{{ lookup('ansible.builtin.env', 'NMS_CH_PASSWORD') }}</password>
                </default>
            </users>
        </clickhouse>

  - name: Start clickhouse-server
    ansible.builtin.systemd:
      state: started
      name: clickhouse-server
```
Getting the ClickHouse dependency installed takes a few steps since we need to add the appropriate repository and signing key.
After ClickHouse is installed, we need to specify a password so we can connect Management Suite to it later.
Finally, we need to make sure ClickHouse is running.

### Add NGINX Management Suite Repo
```yaml
  - name: Add NGINX Signing Key
    ansible.builtin.apt_key:
      url: https://cs.nginx.com/static/keys/nginx_signing.key
  - name: Add NGINX Management Suite Repo
    ansible.builtin.apt_repository:
      repo: deb https://pkgs.nginx.com/nms/ubuntu focal nginx-plus
```
The repository setup is partially completed by the NGINX Pluse install from earlier.
However, we still need to add a new signing key and actually add the repository.

### Install NMS Modules
```yaml
  - name: Install NGINX Instance Manager
    ansible.builtin.apt:
      pkg:
        - nms-instance-manager
  - name: Install NGINX API Connectivity Manager
    ansible.builtin.apt:
      pkg:
        - nms-api-connectivity-manager
  - name: Configure NMS connection to clickhouse
    ansible.builtin.blockinfile:
      path: /etc/nms/nms.conf
      block: |
        clickhouse_address = 127.0.0.1:9000
        clickhouse_username = 'default'
        clickhouse_password = '{{ lookup('ansible.builtin.env', 'NMS_CH_PASSWORD') }}'

  - name: Install python-passlib for htpasswd update
    ansible.builtin.apt:
      pkg:
        - python3-passlib
  - name: Update NMS password
    community.general.htpasswd:
      path: /etc/nms/nginx/.htpasswd
      name: admin
      password: "{{ lookup('ansible.builtin.env', 'NMS_PASSWORD') }}"
  - name: Start nms
    ansible.builtin.systemd:
      state: started
      name: nms
  - name: Restart nginx
    ansible.builtin.systemd:
      state: restarted
      name: nginx
  - name: Install license
    ansible.builtin.uri:
      url: "https://localhost/api/platform/v1/license"
      validate_certs: no
      user: admin
      password: "{{ lookup('ansible.builtin.env', 'NMS_PASSWORD') }}"
      method: PUT
      body_format: json
      body: |
        {
          "desiredState": {
            "content": "{{ lookup('ansible.builtin.file', 'license/nginx.lic') | b64encode }}"
          },
          "metadata": {
            "name": "license"
          }
        }
  - name: Give the license time to take effect
    ansible.builtin.pause:
      seconds: 10
```
At this point installing the Management Suite components is simple.
However, we need to do some work to get things properly configured.
First, we need to make sure that Management Suite is able to connect to ClickHouse.
We can do this by updating the `nms.conf` file with connection information.
The password used here is the same one used when setting up ClickHouse previously.
Next, we need to configure a password for the `admin` user by modifying the `.htpasswd` file.
After everything is configured, we just need to make sure the appropriate services are running.
The license can be applied with a PUT request to the `api/platform/v1/license` endpoint.
It seems that this request can complete before the license is functional.
To make automation more reliable, it helps to wait a few seconds to make sure the license is actually applied.

### Install the Data Plane
```yaml
  - name: Install NGINX Plus
    ansible.builtin.include_role:
      name: nginxinc.nginx
    vars:
      nginx_type: plus
      nginx_license:
        certificate: license/nginx-repo.crt
        key: license/nginx-repo.key
      nginx_modules:
        - njs
  - name: Download NGINX Agent install script
    ansible.builtin.get_url:
      url: "https://{{ lookup('ansible.builtin.env', 'NMS_HOST') }}/install/nginx-agent"
      dest: /etc/nginx-agent.sh
      validate_certs: no
      mode: '0755'
  - name: Install NGINX Agent
    ansible.builtin.shell: "/etc/nginx-agent.sh -g {{ lookup('ansible.builtin.env', 'NMS_CLUSTER_NAME') }}"
  - name: Start nginx-agent
    ansible.builtin.systemd:
      state: started
      name: nginx-agent
```
Most of the Data Plane setup is handled by the nginxinc.nginx role.
To connect the Data Plane instance to Management Suite, we need to download and run the script from the `install/nginx-agent` endpoint of the Management Suite host.

### Install the Developer Portal
```yaml
  - name: Install NGINX Plus
    ansible.builtin.include_role:
      name: nginxinc.nginx
    vars:
      nginx_type: plus
      nginx_license:
        certificate: license/nginx-repo.crt
        key: license/nginx-repo.key
      nginx_remove_license: false
      nginx_modules:
        - njs
  - name: Add NGINX Signing Key
    ansible.builtin.apt_key:
      url: https://cs.nginx.com/static/keys/nginx_signing.key
  - name: Add NGINX Management Suite Repo
    ansible.builtin.apt_repository:
      repo: deb https://pkgs.nginx.com/nms/ubuntu focal nginx-plus
  - name: Install NGINX Developer Portal
    ansible.builtin.apt:
      pkg:
        - nginx-devportal
        - nginx-devportal-ui
  - name: Configure SQLite for Dev Portal
    ansible.builtin.blockinfile:
      path: /etc/nginx-devportal/devportal.conf
      block: |
        DB_TYPE="sqlite"
        DB_PATH="/var/lib/nginx-devportal"
  - name: Start devportal
    ansible.builtin.systemd:
      state: started
      name: nginx-devportal
  - name: Download NGINX Agent install script
    ansible.builtin.get_url:
      url: "https://{{ lookup('ansible.builtin.env', 'NMS_HOST') }}/install/nginx-agent"
      dest: /etc/nginx-agent.sh
      validate_certs: no
      mode: '0755'
  - name: Install NGINX Agent
    ansible.builtin.shell: "/etc/nginx-agent.sh -g {{ lookup('ansible.builtin.env', 'NMS_DEV_CLUSTER_NAME') }}"
  - name: Start nginx-agent
    ansible.builtin.systemd:
      state: started
      name: nginx-agent
```

Just like with setting up the Data Plane instance, we will start by installing NGINX Plus on the Developer Portal instance.
Installing the Developer Portal packages requires setting up the Management Suite repository and signing key.
The Developer Portal requires a database.
For a demo or trial, using a local SQLite database works well.
However, for a more robust production environment, an external PostgreSQL database would be preferred.
The last step is to connect the Developer Portal instance to Management Suite.
A script is fetched from the Management Suite and connected locally in a way that is very similar to connecting a Data Plane instance.
