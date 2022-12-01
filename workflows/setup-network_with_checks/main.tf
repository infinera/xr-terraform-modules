terraform {
  required_providers {
    xrcm = {
      source = "infinera.com/poc/xrcm"
    }
  }
}

module "network_with_versions_check" {
  //source = "git::https://github.com/infinera/terraform-infinera-xr-modules.git//tasks/network_with_versions_check"
  source = "../../tasks/network_with_versions_check"

  assert = var.assert
}

output "message" {
  value = length(module.network_with_versions_check.device_names) > 0 ? "Devices with mismatched version:\n${join("\n", module.network_with_versions_check.device_names)}\n\nContinue to run the workflow with the assumption that the different device software versions are compatible" : ""
}

// Set up the Constellation Network
module "network" {

  source = "git::https://github.com/infinera/terraform-infinera-xr-modules.git//tasks/network"
  //source = "../network"

  network = var.network
  leaf_bandwidth = var.leaf_bandwidth
  hub_bandwidth = var.hub_bandwidth
  client-2-dscg     = var.client-2-dscg
}


