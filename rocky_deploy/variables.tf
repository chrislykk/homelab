variable "pm_password" {
  type      = string
  sensitive = true
}

variable "vm_count" {
  type    = number
  default = 1
}