variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-b"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "public_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
variable "private_cidr" {
  type        = list(string)
  default     = ["192.168.20.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
variable "vpc_name" {
  type        = string
  default     = "base_network"
  description = "VPC network&subnet name"
}

variable "vm_base" {
  type = map(any)
  default = {
    cores         = 2,
    memory        = 2,
    core_fraction = 20,
    image_family  = "ubuntu-2004-lts"
    image_id      = "fd89j9gu6vbcmqkcf4gh"
    disk_size     = 20
  }
}

variable "nat" {
  type = map(any)
  default = {
    cores         = 2,
    memory        = 2,
    core_fraction = 20,
    image_family  = "ubuntu-2004-lts"
    image_id      = "fd80mrhj8fl2oe87o4e1"
    disk_size     = 20
  }
}

variable "lamp" {
  type = map(any)
  default = {
    cores         = 2,
    memory        = 2,
    core_fraction = 20,
    image_family  = "lamp"
    image_id      = "fd827b91d99psvq5fjit"
    disk_size     = 20
  }
}

variable "user_name" {
  type = string
  default = "ubuntu"
}

variable "bucket" {
  type = string
  default = "bucket"
}

variable "ig-sa" {
  type = string
  default = "ig-sa"
}

variable "nlb" {
  type = string
  default = "nlb"
}

variable "group-nlb" {
  type = string
  default = "group-nlb"
}