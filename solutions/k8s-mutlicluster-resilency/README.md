# Multi-Cluster Application Resilience

## Solution Description
<img src="images/vk8s-use-case.png" height="75%" width="75%">

This solution example demostrates automated kubenetes application namespace failover leveraging F5 Distributed Cloud, specificlly, the following components of Application Management:

* [Domain Delegation](https://docs.cloud.f5.com/docs/how-to/app-networking/domain-delegation)
* [Virtual Kubenetes](https://docs.cloud.f5.com/docs/how-to/app-management/vk8s-deployment)
* [HTTP Load Balancers](https://docs.cloud.f5.com/docs/how-to/app-networking/http-load-balancer)

That extends into, provides resilency for, AWS EKS microservices application workload with F5 Distributed Cloud [Managed K8s](https://docs.cloud.f5.com/docs/how-to/app-management/create-deploy-managed-k8s)

The solution architecture, along with IaC deployment code and example microservices application, demostrates that with minimal configuration steps and DNS integration.  

Other microservices deployment scenarios that this solution example could be applied too, outside of the scope of this example;

* blue/green
* canary
* a/b testing
* recreate

> *_credit_: ContainerSolutions for [deployment models](https://github.com/ContainerSolutions/k8s-deployment-strategies)*


## Value

Synchronize and seamlessly failover an entire Kubernetes cluster’s application services from one data center to another.

Specifically, this solution solves the following use case:

```gherkin
Given a running microservices application workload 
    And business requires minimal outage of those services
When an event or indicdent occurs
Then automated failover or isolation of site happens
    And end-users/consumers do not experience outage of services
```

## Demo
![Demo Video](videos/k8s-usecase-vid04raw_v04.mkv)

## Demostration of the Solution

To force an incident outside of normal application deployment for this example this can be achieved by simply deleting the AWS EKS Microservices application deployment.

This is achieved in the following steps, from the solution deployment;

### *_Tasks:_*

1. change path to the Google MicroServices OnlineShop;

```shell
cd $HOME/microservices-demo/release
```

2. remove the deployment with `kubectl`

```shell
kubectl delete -f release/kubernetes-manifests.yaml
```

3. to confirm the application is removed;

```shell
kubectl get pods -o=wide -n=default
```

4. Validate failover resilency by opening a broswer to [https://shop.<example.com>], replacing example.com with the FQDN that was configured as part of the solution deployment.

This can also be validated either programmaticly via API, with the F5 Distributed Cloud console as seen in the attached demo video or simple network tools such as `dig`.

