# Nuon FAQ, Examples, and Tips

As I use Nuon more and more, I find myself documenting things that I learn along the way. This document serves as a collection of these FAQ, examples, and tips.

## What is Nuon?
Enterprise customers assume risk of data loss when using a software vendor's cloud offering. Software vendors also spend precious resources reinventing the wheel to offer cloud offerings. What if there was a way for customers to run vendor software on their own infrastructure, but managed by the vendor? What if the vendor could offer this solution for a lot less resources than building a cloud offering?

That is called Bring-your-own-cloud (BYOC) and Nuon is a platform that automates the deployment and management of vendor software on customer infrastructure. It is a platform that allows vendors to offer their software as a service, while customers retain control over their data and infrastructure.

## Who should use Nuon?
Software vendors who want to provide single-tenant or customer-cloud offerings to their customers, but do not want to build and maintain a cloud offering. 

Nuon is also for customers who want to run vendor software on their own infrastructure, but do not want to manage the deployment and operations of the software themselves. e.g., a Global 2000 company toiling to manage their globally distributed instances of self-hosted vendor software products.

Customers can also use Nuon to manage internally-developed software deployed in a myriad of ways throughout their organization.

## Architecture

The control plane consists of an api server, a build runner, web dashboard application, and a database. The nuon CLI interacts with the control plane including uploading 1:many application configurations which are a set of toml, IaC, and script files that define how to deploy the vendor software on customer infrastructure. The control plane can be hosted by Nuon or deployed on the customer's infrastructure aka BYOC Nuon.

The build runner generates an artifact for each version of the vendor's app e.g., a CloudFormation stack or comparable other cloud IaC standard, which is opened in the customer's cloud account or through a self-service portal. This creates a VM with the Nuon install runner that phones home to the Nuon control plane to register itself. The install runner, a systemd service along with a Docker systemd service on the VM, then runs the scripts and applies the infrastructure as code (IaC) to deploy the vendor software on the customer's infrastructure. This is called day 1 operations. The control plane never outbound communicates with the install runners in the customer infrastructure, it only receives inbound requests from the install runners.

Day 2 operations are the 1:many Nuon actions that the vendor defines and which are executed by the install runner to monitor, manage, and upgrade the vendor software on the customer's infrastructure.

All of these events are managed by an underlying Temporal durable execution engine which allows for long-running workflows and retries in case of failures, and the event logging in OTel format are sent to a  Clickhouse database in the Nuon control plane for analytics and monitoring.


## Installation

### CLI

```bash
brew install nuonco/tap/nuon
```

### Control Plane

For PoCs, Nuon hosts the control plane on a public cloud. For production deployments, you can deploy the control plane on your own infrastructure using the [BYOC Nuon application configuration repository](https://github.com/nuonco/byoc/tree/main). In other words, Nuon is used to deploy Nuon's control plane in a customer's cloud. 

## Usage

### CLI
```bash
nuon --help
```

Or the installation script:
```bash
curl -fsSL https://nuon-artifacts.s3.us-west-2.amazonaws.com/cli/install.sh | bash
```

### Dashboard

If using Nuon's hosted control plane, you can access the dashboard at [https://app.nuon.co](https://https://app.nuon.co/o). If you are running your own control plane, you can access the dashboard at `https://<your-control-plane-ip>` specified during the config.

## Changelog
For the latest changes, see [Updates](https://docs.nuon.co/updates/)

## Examples

### eks-simple
This example repository [eks-simple](https://github.com/nuonco/demo/tree/main/eks-simple) creates an EKS cluster with a `whoami` application deployed on it. I've confirmed it works and it is well maintained including the new directory structure for the app config.

## Resources

- [Nuon documentation](https://docs.nuon.co/)
- [Nuon GitHub repository](https://github.com/nuonco)
- [BYOC Nuon app config](https://github.com/nuonco/byoc/tree/main)
- [EKS teardown script](https://github.com/nuonco/sandboxes/blob/main/aws-eks/error-destroy.sh)
- [Nuon Terraform Provider](https://registry.terraform.io/providers/nuonco/nuon/latest/docs)
- [Nuon Terraform modules](https://registry.terraform.io/modules/nuonco/)
- [Nuon Slack channel](https://join.slack.com/t/nuoncommunity/shared_invite/zt-1q323vw9z-C8ztRP~HfWjZx6AXi50VRA)
- [Nuon components](https://github.com/nuonco/components)
- [Nuon sandboxes](https://github.com/nuonco/sandboxes)
- [Nuon Runner public components and scripts](https://github.com/nuonco/runner)
- [Latest EKS sandbox repo](https://github.com/nuonco/aws-eks-sandbox)
- [Latest EKS Karpenter sanbox repo](https://github.com/nuonco/aws-eks-karpenter-sandbox)
- [eks-simple repo](https://github.com/nuonco/demo/tree/main/eks-simple)