// If this flag is set the module shall stop executing if there is any mismatched ID device 
// Otherwise run with the filtered device to cleanup the network for the mismatched ID devices
variable assert {
  type = bool
  default = true
}

variable "devices_file" {
  type    = string
   default = "./tf_devices.json"
}

