locals {
  limit_count = var.ssh_config_update != "true" ? 0 : local.num_boxes
  all_tags = aws_instance.kdevops_instance.*.tags
  shorthosts = [
    for tags in local.all_tags:
      format("%s", lookup(tags, "Name"))
  ]
  all_ipv4s = aws_eip.kdevops_eip.*.public_ip
  ipv4s = [
    for ip in local.all_ipv4s:
      ip == "" ? "0.0.0.0" : ip
  ]
}

module "ssh_config_update_host_entries" {
  source  = "mcgrof/add-host-ssh-config/kdevops"
  version = "2.1.2"

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
  kexalgorithms = var.ssh_config_kexalgorithms == "" ? "" : var.ssh_config_kexalgorithms
}
