resource "yandex_vpc_network" "base_network" {
  name = var.vpc_name
}

resource "yandex_vpc_security_group" "lamp-sg" {
  name       = "lamp-sg"
  network_id = yandex_vpc_network.base_network.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.base_network.id
  v4_cidr_blocks = var.public_cidr
}

resource "yandex_vpc_route_table" "private_route" {
  name = "private-route"
  network_id = yandex_vpc_network.base_network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.nat_instance.network_interface.0.ip_address
  }
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.base_network.id
  v4_cidr_blocks = var.private_cidr
  route_table_id = yandex_vpc_route_table.private_route.id
}