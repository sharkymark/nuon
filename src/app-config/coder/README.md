{{ $region := .nuon.cloud_account.aws.region }}


<center>
  <img src="https://raw.githubusercontent.com/coder/presskit/refs/heads/main/logos/coder_logo_transparent_black.svg"/>
  <h1>Coder</h1>

## What is Coder?
Coder is a Cloud Development Environment (CDE) platform that enables developers to create, manage, and scale development environments in the cloud. This Nuon app config deploys a light-weight Coder instance on AWS using Amazon EKS, meant for demonstration purposes only. Review the Coder docs for how it deploys on [Kubernetes](https://coder.com/docs/install/kubernetes) and visit the [Coder OSS repository](https://github.com/coder/coder) for more information.

## Coder architecture
Coder consists of a PostgreSQL database, an API server, a web dashboard, and a Terraform provsioner server that runs `terraform plan`, `terraform apply`, and `terraform destroy` commands to build development development environments on any cloud or on-premises infrastructure.  See the [Coder architecture diagram](https://coder.com/docs/admin/infrastructure/architecture) for more details.

## Coder Access URL

{{ if .nuon.install.sandbox.outputs.nuon_dns.public_domain.name }}
`https://{{.nuon.install.sandbox.outputs.nuon_dns.public_domain.name}}`
{{ end }}

  <small>
{{ if .nuon.install_stack.outputs }}
AWS | {{ dig "account_id" "000000000000" .nuon.install_stack.outputs }} | {{ dig "region" "xx-vvvv-00" .nuon.install_stack.outputs }} | {{ dig "vpc_id" "vpc-000000" .nuon.install_stack.outputs }}
{{ else }}
AWS | 000000000000 | xx-vvvv-00 | vpc-000000
{{ end }}
  </small>
</center>

{{ if and .nuon.install_stack.populated }}

## Installation

{{ if .nuon.install_stack.quick_link_url }}

- [AWS CloudFormation QuickLink URL]({{ .nuon.install_stack.quick_link_url }}) {{ else }}
- Generating Quick Link

{{ end }}

{{ if .nuon.install_stack.template_url }}

- [AWS CloudFormation Template URL]({{ .nuon.install_stack.template_url }})
- [Compose
  Preview](https://{{ $region }}.console.aws.amazon.com/composer/canvas?region={{ $region }}&templateURL={{ .nuon.install_stack.template_url}}&srcConsole=cloudformation)
  {{ else }}
- Generating CloudFormation Template URL

{{ end }}

<details>
<summary>Full Template</summary>
{{ $template := .nuon.install_stack.template_json | fromJson }}
<pre>{{ $template | toPrettyJson }}</pre>
</details>
{{ else }}
No install stack configured.
{{ end }}

## Application

If nuon_dns is enabled. {{ if .nuon.sandbox.outputs }}

| Service | URL                                                                                                                                   |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| coder  | [{{ .nuon.sandbox.outputs.nuon_dns.public_domain.name }}](https://app.{{ .nuon.sandbox.outputs.nuon_dns.public_domain.name }}) |

{{ else }} Results will be visible after the sandbox is deployed. {{ end }}

## Accessing the EKS Cluster

1. Add an access entry for the relevant role.
2. Grant the following perms: AWSEKSAdmin, AWSClusterAdmin.gtg
3. Add the cluster kubeconfig w/ the following command.

<pre>
aws --region {{ .nuon.install_stack.outputs.region }} \
    --profile your.Profile eks update-kubeconfig      \
    --name {{ dig "outputs" "cluster" "name" "$cluster_name" .nuon.sandbox }} \
    --alias {{ dig "outputs" "cluster" "name" "$cluster_name" .nuon.sandbox }}
</pre>

## State

### Install Stack

<details>
  <summary>Install Stack</summary>
  <pre>{{ toPrettyJson .nuon.install_stack }}</pre>
</details>

### Sandbox

{{ if .nuon.sandbox.outputs }}

<details>
<summary>Sandbox State</summary>
<pre class="json">{{ toPrettyJson .nuon.sandbox.outputs }}</pre>
</details>

{{ else }}

<pre>Working on it</pre>

{{ end }} 9

### Actions

<details>
<summary>.nuon.actions</summary>
<pre>{{ toPrettyJson .nuon.actions }}</pre>
</details>

### Components

<details>
<summary>.nuon.components</summary>
<pre>{{ toPrettyJson .nuon.components }}</pre>
</details>

### Inputs

<details>
<summary>.nuon.inputs</summary>
<pre>{{ toPrettyJson .nuon.inputs }}</pre>
</details>

### Full State

<details>
<summary>Full Install State</summary>
<pre>{{ toPrettyJson .nuon }}</pre>
</details>
