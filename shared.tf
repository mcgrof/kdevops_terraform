# Generic import of data. Terraform doesn't support reading YAML files
# directly. Instead we need to use a terraform plugin for that. We do
# this so we can just use *one* file for provisioning which is shared
# for both simple Vagrant solutions and cloud terraform configurations.
#
# To use this just symlink to this in your respective provider directory.
# Terraform will process all *.tf files in alphabetical order, but the
# order does not matter as terraform is declarative.

# This lets you override the node configuraiton file with an environment
# variable, TN_VAR_DEVOPS_NODE_CONFIG.

variable "file_yaml_vagrant_boxes" {
    description = "Path to the yaml file which has the vagrant_boxes declared as list"
    default = "../nodes.yaml"
}

variable "ssh_config" {
    description = "Path to your ssh_config"
    default = "/dev/null"
}

variable "ssh_config_update" {
    description = "Set this to true if you want terraform to update your ssh_config with the provisioned set of hosts"
    default = "true"
}

variable "ssh_config_user" {
    description = "If ssh_config_update is true, and this is set, it will be the user set for each host on your ssh config"
    default = ""
}

variable "ssh_config_use_strict_settings" {
    description = "Whether or not to use strict settings on ssh_config"
    default = "yes"
}

variable "ssh_config_backup" {
    description = "Set this to true if you want to backup your ssh_config per update"
    default = "true"
}

provider "null" {
  # any non-beta version >= 2.0.0 and < 2.1.0, e.g. 2.0.1
  version = "~> 2.1"
}

# We'd have to update our Makefiles to do the right thing, if we
# add this, terraform can't find the stupid plugin.
#provider "yaml" {
# any non-beta version >= 2.0.0 and < 2.1.0, e.g. 2.0.1
#  version = "~>2.0"
#}

locals {
  input = "${var.file_yaml_vagrant_boxes}"
}

# https://github.com/ashald/terraform-provider-yaml
data "yaml_map_of_strings"  "normal" { input = "${file(local.input)}" }
data "yaml_map_of_strings"  "flat"   {
	input = "${file(local.input)}"
	flatten="/"
}

# You *must* have a section your YAML file with "vagrant_boxes" declaring a
# list of hosts.
data "yaml_list_of_strings" "list"   { input = "${data.yaml_map_of_strings.normal.output["vagrant_boxes"]}" }

locals {
  vagrant_num_boxes = "${length(data.yaml_list_of_strings.list.output)}"
}

locals {
  num_boxes = "${var.limit_boxes == "yes" ? min(local.vagrant_num_boxes, var.limit_num_boxes) : local.vagrant_num_boxes }"
}
