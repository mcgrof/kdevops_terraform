locals {
  limit_count = var.ssh_config_update != "true" ? 0 : local.num_boxes
  shorthosts = azurerm_linux_virtual_machine.kdevops_vm.*.name
  ipv4s = data.azurerm_public_ip.public_ips.*.ip_address
}

module "ssh_config_update_host_entries" {
  source  = "mcgrof/add-host-ssh-config/kdevops"
  version = "1.0.2"

  ssh_config = var.ssh_config
  update_ssh_config_enable = local.limit_count > 0 ? "true" : ""
  cmd = "update"
  shorthosts = join(",", slice(local.shorthosts, 0, local.limit_count))
  hostnames = join(",", slice(local.ipv4s, 0, local.limit_count))
  ports = "22"
  user = var.ssh_config_user == "" ? "" : var.ssh_config_user
  id = replace(var.ssh_config_pubkey_file, ".pub", "")
  strict = var.ssh_config_use_strict_settings != "true" ? "" : "true"
  use_backup = var.ssh_config_backup != "true" || var.ssh_config == "/dev/null" ? "" : "true"
  backup_postfix = "kdevops"
}

resource "null_resource" "ansible_call" {
  provisioner "local-exec" {
    command = "${local.ansible_cmd}'"
  }
  depends_on = [ module.ssh_config_update_host_entries ]
}
