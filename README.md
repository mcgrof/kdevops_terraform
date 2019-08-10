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
ssh_pubkey_data = "ssh-rsa AAASNIP"
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

AWS is supported. More documentation needs to be added.

Further information
--------------------

For further examples refer to one of this role's users, the
[https://github.com/mcgrof/kdevops](kdevops) project or the
[https://github.com/mcgrof/oscheck](oscheck) project from where
this code originally came from.

License
-------

GPLv2
# kdevops

kdevops is a sample framework which lets you easily get your Linux devops
environment going for whatever use case you have. The first use case is to
provide a devops environment for Linux kernel development testing, and hence
the name. The goal behind this project is to let you *easily fork it* and
re-purpose it for whatever kdevops needs you may have.

kdevops relies on vagrant, terraform and ansible to get you going with whatever
your virtualization / bare metal / cloud provisioning environment easily.
It realies heavily on public ansible galaxy roles. This lets us share code
with the community work and allows us to not have to carry all that code
in this project. Each role focuses on one specific small goal of the
development focus of kdevops. kdevops then is a bare bones sample demo
project of the kdevops ansible roles made available to the community.
