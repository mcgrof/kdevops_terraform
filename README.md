kdevops_terraform
=================

kdevops_terraform is an ansible role which deploys a set of community shared
kdevops terraform file into your project. This ansible role copies all the
terraform files needed to run terraform with different supported cloud
providers. You will be able to provision your target hosts and ssh into
them as we update your ~/.ssh/config for you as well. When the cloud
provider did the right thing in the backend, you should be able to ssh
into the hosts as soon as terraform completes its work.

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
  * aws
  * gce
  * azure

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

You'll first need to set up your terraform.tfvars file for your cloud
provider, this is documented below for each cloud provider. After
that you just run:

```bash
cd you_provider
make deps
terraform init
terraform plan
terraform apply
```

# Enabling updating your ssh configuration file

This role supports allowing you to update your ssh configuraiton file, this
is typically your `~/.ssh/config file`, however you can specify a different
file.

Below is an example set of entries you'd have to add to your own cloud specific
`terraform.tfvars` file to enable updating your ssh configuration when the
file:

```
ssh_config = "~/.ssh/config"
ssh_config_update = "true"
ssh_config_use_strict_settings = "true"
ssh_config_backup = "true"
```

Enabling the `ssh_config_use_strict_settings` setting will add these
entries for each host on your configuration file:

```
	UserKnownHostsFile /dev/null
	StrictHostKeyChecking no
	PasswordAuthentication no
	IdentitiesOnly yes
	LogLevel FATAL
```

Enabling `ssh_config_backup` will create a backup of your ssh config file.
We remove old host entries in one shot on your configuration file for the hosts
being added, as such we backup the configuration file on removal only once, for
instance `~/.ssh/config.kdevops.backup.removal`. We backup the configuration
on addition for each host, `~/.ssh/config.kdevops.backup.add.0` for the first
host entry, `~/.ssh/config.kdevops.backup.add.1` for the second host entry,
and so on.

The default is to not enable ssh configuraiton updates.

# Initial debugging: limiting the number of host provisioned

When you first starting off you may want to just enable 1 or 2 hosts
to provision, as otherwise you will have to wait quite a bit of time
for all hosts on a project to provision. We have support to do this on
all providers with the `limit_num_boxes` variable. For instance the
following on terraform.tfvars would ensure only 2 hosts are provisioned
on the cloud:

```
limit_boxes = "yes"
limit_num_boxes = 2
```

It is a good idea to use this when doing your first test.

# Destroying provisioned hosts

Since you may be paying for your cloud solution, destroy them after
instantiating them otherwise you'll pay for lingering hosts. To do so:

```
terraform destroy
```

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
client_certificate_path = "./service-principal.pfx"
client_certificate_password = "my-cool-passworsd"
tenant_id = "SOME-GUID"
application_id = "SOME-GUID"
subscription_id = "SOME-GUID"
ssh_username = "yourcoolusername"
ssh_pubkey_file = "~/.ssh/minicloud.pub"

# Limit set to 2 to enable only 2 hosts form this project
limit_boxes = "yes"
limit_num_boxes = 2

# Updating your ssh config not yet supported on Azure :(
#ssh_config = "~/.ssh/config"
#ssh_config_update = "true"
#ssh_config_use_strict_settings = "true"
#ssh_config_backup = "true"
```

## Openstack

Openstack is supported. This solution relies on the clouds.yaml file for
openstack configuration. This simplifies setting up authentication
considerably.

### Minicloud Openstack support

minicloud has a custom setup where the you have to ssh with a special port
depending on the IP address you get, if you enable minicloud we do this
computation for you and tell you where to ssh to, but we also have support
to update your ~/ssh/config for you.

Please note that minicloud takes a while to update its ports / mac address
tables, and so you may not be able to log in until after about 5 minutes after
you are able to create the nodes. Have patience.

Your terraform.tfvars may look something like:

```
instance_prefix = "my-random-project"

image_name = "Debian 10 ppc64le"
flavor_name = "minicloud.tiny"

# Limit set to 2 to enable only 2 hosts form this project
limit_boxes = "yes"
limit_num_boxes = 2

ssh_pubkey_file = "~/.ssh/minicloud.pub"

ssh_config = "~/.ssh/config"
ssh_config_user = "debian"
ssh_config_update = "true"
ssh_config_use_strict_settings = "true"
ssh_config_backup = "true"

```

## AWS - Amazon Web Services

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

# Limit set to 2 to enable only 2 hosts form this project
limit_boxes = "yes"
limit_num_boxes = 2

ssh_username = "mcgrof"
ssh_pubkey_file = "~/.ssh/my-aws.pub"

ssh_config = "~/.ssh/config"
ssh_config_update = "true"
ssh_config_use_strict_settings = "true"
ssh_config_backup = "true"
```

To read more about shared credentails refer to:

  * https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
  * https://docs.aws.amazon.com/powershell/latest/userguide/shared-credentials-in-aws-powershell.html

## GCE - Google Cloude Compute

This ansible role also supports the GCE on terraform. Below is an example
terraform.tfvars you may end up with:

```
project = "demo-kdevops"
ssh_username = "mcgrof"
limit_num_boxes = 2
ssh_pubkey_file = "~/.ssh/my-gce.pub"

# Limit set to 2 to enable only 2 hosts form this project
limit_boxes = "yes"
limit_num_boxes = 2

ssh_config = "~/.ssh/config"
ssh_config_update = "true"
ssh_config_use_strict_settings = "true"
ssh_config_backup = "true"
```

To ramp up, you'll need to get the json for your service account through
the IMA interface. This is documented below. The default name for the
json credentails file is account.json, you can override this and its
path with:

```
credentials = /home/foo/path/to/some.json
```

https://www.terraform.io/docs/providers/google/getting_started.html
https://www.terraform.io/docs/providers/google/index.html
https://cloud.google.com/iam/docs/granting-roles-to-service-accounts#granting_access_to_a_service_account_for_a_resource

Further information
--------------------

For further examples refer to one of this role's users, the
[https://github.com/mcgrof/kdevops](kdevops) project or the
[https://github.com/mcgrof/oscheck](oscheck) project from where
this code originally came from.

License
-------

GPLv2
