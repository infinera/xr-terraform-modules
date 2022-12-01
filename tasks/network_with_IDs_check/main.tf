
terraform {
  required_providers {
    xrcm = {
      source = "infinera.com/poc/xrcm"
    }
  }
}

provider "xrcm" {
  username = "dev"
  password = "xrSysArch3"
  host     = "https://sv-kube-prd.infinera.com:443"
}

// This module initializes the:
// network
// bandwidht
// service
module  "get_devices_with_different_ids"{
  source = "git::https://github.com/infinera/terraform-infinera-xr-modules.git//utils/get_devices_with_different_ids"
  //source = "../../utils/get_devices_with_different_ids"

  device_names = [for k,v in var.network.setup: k]
  state = "ONLINE"
  devices_file = var.devices_file
  save_file = false //var.save_file
}

locals {
  id_mismatched_devices = module.get_devices_with_different_ids.devices
  ids_mismatched = length(local.id_mismatched_devices) > 0
  deviceid_checks_outputs = local.ids_mismatched ? [for k,v in local.id_mismatched_devices : "Module:${upper(k)}, SavedID: ${v.saved_deviceid}, DeviceID: ${v.network_deviceid}"] : []
  device_names = local.ids_mismatched != null ? [for k,v in local.id_mismatched_devices : k ] : []
  upper_device_names = [for k in local.device_names : upper("${k}")]
}

output "message" {
  value = local.ids_mismatched && !var.assert ? "Not Assert. ID(s) Mismatched:\n${join("\n", local.deviceid_checks_outputs)}\n\nAction: Continue to run with filtering the mismatched devices listed above" : ""
}

// check module with same name but ID is diff
data "xrcm_check" "check_deviceid_mismatched" {
  depends_on = [module.get_devices_with_different_ids.hubs, module.get_devices_with_different_ids.leafs] //, module.print_message]

  count = var.assert ? 1 : 0
  condition = local.ids_mismatched
  description = "Devices ids are mismatched: ${join(", ", local.upper_device_names)}"
  throw = "ID(s) Mismatched:\n${join("\n", local.deviceid_checks_outputs)}"
}

output "id_mismatched_devices" {
   value = local.id_mismatched_devices
}

output "device_names" {
  value = local.device_names
}


