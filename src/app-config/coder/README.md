<center>

  <video autoplay loop muted playsinline width="640" height="360">
    <source src="https://coder.together.agency/videos/logo/sections/0/content/9/value/video.mp4" type="video/mp4">
    Your browser does not support the video tag.
  </video>
</center>


Coder Access URL: https://{{.nuon.install.sandbox.outputs.nuon_dns.public_domain.name}}

Nuon Install Id: {{ .nuon.install.id }}

AWS Region: {{ .nuon.install_stack.outputs.region }}

> A wildcard DNS record needs to be manually created for the Coder app to be accessible. Create a CNAME record for `*.{{.nuon.install.sandbox.outputs.nuon_dns.public_domain.name}}` that points to the ALB DNS name

## Full State

<details>
<summary>Full Install State</summary>
<pre>{{ toPrettyJson .nuon }}</pre>
</details>

<center>

## What is Coder?
Coder is a Cloud Development Environment (CDE) platform that enables developers to create, manage, and scale development environments in the cloud. This Nuon app config deploys a light-weight Coder instance on AWS using Amazon EKS, meant for demonstration purposes only. Review the Coder docs for how it deploys on [Kubernetes](https://coder.com/docs/install/kubernetes) and visit the [Coder OSS repository](https://github.com/coder/coder) for more information.

## Coder architecture
Coder consists of a PostgreSQL database, an API server, a web dashboard, and a Terraform provisioner server that runs `terraform plan`, `terraform apply`, and `terraform destroy` commands to build development development environments on any cloud or on-premises infrastructure.  See the [Coder architecture diagram](https://coder.com/docs/admin/infrastructure/architecture) for more details.

## Coder Resources

[Coder Environment Variable docs](https://coder.com/docs/reference/cli/server)

[Coder Releases](https://github.com/coder/coder/releases/)
</center>
