kdevops_terraform
=================

kdevops_terraform is an ansible role which deploys a set of community shared
kdevops terraform file into your project. This ansible role copies all the
terraform files needed to run terraform with different supported cloud
providers.

The goal behind this ansible role to allow the ability to *share* the same
set of terraform files between projects, and gives the terraform files a home
to allow contributors to advance it, and document it.

Requirements
------------

You must have terraform installed, terrafrom is used to easily deploy cloud
servers.

# Providers supported

 The following cloud providers are supported:

  * openstack
  * azure
  * aws

Dependencies
------------

None.

Example Playbook
----------------

Below is an example playbook, it is used on the kdevops project,
so kdevops/playbooks/kdevops_vagrant.yml file:

```
---
- hosts: localhost
  roles:
    - role: kdevops_terraform
```

In this particular case note how localhost is used. This is because we are
provisioning the terraform files to your terraform/ directory locally.
You could obviously use a different host though, it does not have
to be localhost.

# Terraform setup

Terraform is used to deploy hosts on for cloud platforms such as Azure, AWS,
OpenStack.

Node configuration is shared between cloud proivers, and by default kdevops
terraform relies on the file `nodes.yaml`. You can also override this with
the a configuration variable for your respective cloud terraform.tfvars
file:

  * file_yaml_vagrant_boxes

# Install dependencies

```bash
make deps
```

# Use a cloud provider

```bash
cd you_provider
make deps
terraform init
terraform plan
terraform apply
```

Below are more cloud provider specific instructions.

## Azure

Read these pages:

https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_certificate.html
https://github.com/terraform-providers/terraform-provider-azurerm.git
https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-create-complete-vm
https://wiki.debian.org/Cloud/MicrosoftAzure

But the skinny of it:

```
$ openssl req -newkey rsa:4096 -nodes -keyout "service-principal.key" -out "service-principal.csr"
$ openssl x509 -signkey "service-principal.key" -in "service-principal.csr" -req -days 365 -out "service-principal.crt"
$ openssl pkcs12 -export -out "service-principal.pfx" -inkey "service-principal.key" -in "service-principal.crt"
```

Use the documentation to get your tentant ID, the applicaiton id, the 
subscription ID. You will need this to set these variables up:

```
$ cat terraform.tfvars
# Do not check this into SCM.
client_certificate_path = "./service-principal.pfx"
client_certificate_password = "my-cool-passworsd"
tenant_id = "SOME-GUID"
application_id = "SOME-GUID"
subscription_id = "SOME-GUID"
ssh_username = "yourcoolusername"
ssh_pubkey_file = "~/.ssh/minicloud.pub"
```

## Openstack

Openstack is supported now. This has been tested with the minicloud openstack.
This solution relies on the new clouds.yaml file for openstack configuration.
This simplifies things considerably.

Since minicloud is an example cloud solution and, since it also has a custom
setup where the you have to ssh with a special port depending on the IP address
you get, if you enable minicloud we do this computation for you and tell you
where to ssh to. Just follow the instructions at the output of `terraform
plan` to be able to ssh into the open cloud nodes. Please note that minicloud
takes a while to update its ports / mac address tables, and so you may not be
able to log in until after about 5 minutes after you are able to create the
nodes. Have patience.

## AWS

AWS is supported. For authentication we rely on the shared credentials file,
so you must have the file:

```
~/.aws/credentials
```

This file is rather simple with a structure as follows:

```
[default]
aws_access_key_id = SOME_ACCESS_KEY
aws_secret_access_key = SECRET_KEY
```

The profile above is "default", and you can multiple profiles. By default
our tarraform's aws vars.tf assumes ~/.aws/credentials as the default
credentials location, and the profile as "default". If this is different
for you, you can override with the variables:

```
aws_shared_credentials_file
aws_profile
```

But if your credentials file is `~/.aws/credentials` and the profile
target is `default`, then your minimum `terraform.tfvars` file should look
something like this:

```
aws_region = "us-west-1"

ssh_username = "mcgrof"
ssh_pubkey_file = "~/.ssh/my-aws.pub"
```

To read more about shared credentails refer to:

  * https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
  * https://docs.aws.amazon.com/powershell/latest/userguide/shared-credentials-in-aws-powershell.html

Further information
--------------------

For further examples refer to one of this role's users, the
[https://github.com/mcgrof/kdevops](kdevops) project or the
[https://github.com/mcgrof/oscheck](oscheck) project from where
this code originally came from.

License
-------

GPLv2
