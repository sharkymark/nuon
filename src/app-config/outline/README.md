<center>

<img src="https://avatars.githubusercontent.com/u/1765001?s=200&v=4"
     alt="Outline" width="160" />

<h1>Outline App Config</h1>

Access URL: [https://{{.nuon.install.sandbox.outputs.nuon_dns.public_domain.name}}](https://{{.nuon.install.sandbox.outputs.nuon_dns.public_domain.name}})

Nuon Install Id: {{ .nuon.install.id }}

AWS Region: {{ .nuon.install_stack.outputs.region }}

## What is Twenty?

[Outline](https://www.getoutline.com/) is a modern knowledge base and wiki for teams and a self-hosted alternative to SaaS-based Notion. It helps you share information, collaborate on documents, and keep your team aligned.

</center>

## Full State

<details>
<summary>Full Install State</summary>
<pre>{{ toPrettyJson .nuon }}</pre>
</details>

## Outline Resources

[Outline image tags](https://hub.docker.com/r/outlinewiki/outline/tags)

[Repo](https://github.com/outline/outline)

[Helm chart](https://github.com/encircle360-oss/outline-helm-chart)

[values.yaml](https://github.com/encircle360-oss/outline-helm-chart/blob/main/values.yaml)

[AWS Instance Types](https://aws.amazon.com/ec2/instance-types/)

[AWS T3 and T3a Instances](https://aws.amazon.com/ec2/instance-types/t3/)
