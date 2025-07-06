<center>

  <img src="https://github.com/coder/coder/blob/main/docs/images/logo-black.png"/>
  <h1>Coder</h1>

## Coder Access URL

{{ if .nuon.install.sandbox.outputs.nuon_dns.public_domain.name }}
`https://{{.nuon.install.sandbox.outputs.nuon_dns.public_domain.name}}`
{{ end }}

Nuon Install Id: {{ .nuon.install.id }}
AWS Region: {{ .nuon.install_stack.outputs.region }}
AWS Account Id: {{ .nuon.install_stack.outputs.account.id }}
Namespace: {{.nuon.install.sandbox.outputs.namespaces}}

</center>

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
