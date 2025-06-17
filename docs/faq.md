# Frequently Asked Questions

(sorted by category)

<details>
<summary>CLI</summary>
<details>
<summary>How do I create a new app and sync it?</summary>
Use the <code>nuon apps create -n <your app name> --no-template</code> command to create a new app, and then use <code>nuon apps sync .</code> to sync the local directory of app config files with the app.
</details>

<details>
<summary>There are two <code>sync</code> sub-commands under <code>nuon apps</code>, what is the difference?</summary>
<code>nuon apps sync .</code> is a more advanced sync that does some validation and knows how to construct a config from a well-known directory structure. <code>nuon apps sync-dir</code> used to do this, but will be deprecated.

> Note: The directory that you run `nuon apps sync` in, must be the same name as the app created in `nuon apps create -n <your app name> --no-template`.
</details>

<details>
<summary>Where are org, app and install current contexts stored?</summary>
The current contexts are stored in the local <code>~/.nuon</code> file along with the Nuon api key.
</details>

<details>
<summary>How do I see detailed error messages?</summary>
Set the environment variable <code>export NUON_DEBUG=true</code> then use the CLI commands as usual. This will enable debug logging and show more detailed error messages.
</details>

</details>

<details>
<summary>AWS</summary>

<details>
<summary>As a customer deploying an app from the Nuon dashboard, how do I tie my AWS access key and secret access key to the app install?</summary>
When you click on the Nuon-generated CloudFormation Stack Link in the Nuon dashboard, that opens in the customer's AWS account. The initial install runner and app install is done with the customer's AWS credentials. Nuon never will have access to these credentials.  All of those Nuon control plane activities like creating app configs and building components, leverage the AWS (or equivalent cloud) credentials of Nuon-hosted control plane or the customer-hosted control plane.

</details>

</details>