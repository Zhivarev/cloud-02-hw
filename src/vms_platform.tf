resource "yandex_compute_instance" "public_instance" {
  name        = "public-instance"
  hostname    = "public-instance"
  platform_id = "standard-v1"
  boot_disk {
    initialize_params {
      image_id = var.vm_base.image_id
      size     = var.vm_base.disk_size
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }
  resources {
    cores         = var.vm_base.cores
    memory        = var.vm_base.memory
    core_fraction = var.vm_base.core_fraction
  }
  metadata = local.ssh_keys_and_serial_port
}

resource "yandex_compute_instance" "private_instance" {
  name        = "private-instance"
  hostname    = "private-instance"
  platform_id = "standard-v1"
  boot_disk {
    initialize_params {
      image_id = var.vm_base.image_id
      size     = var.vm_base.disk_size
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false
  }
  resources {
    cores         = var.vm_base.cores
    memory        = var.vm_base.memory
    core_fraction = var.vm_base.core_fraction
  }
  metadata = local.ssh_keys_and_serial_port
}

resource "yandex_compute_instance" "nat_instance" {
  name        = "nat-instance"
  hostname    = "nat"
  platform_id = "standard-v1"
  boot_disk {
    initialize_params {
      image_id = var.nat.image_id
      size     = var.nat.disk_size
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
    ip_address         = "192.168.10.254"
  }
  resources {
    cores         = var.nat.cores
    memory        = var.nat.memory
    core_fraction = var.nat.core_fraction
  }
  metadata = local.ssh_keys_and_serial_port
}

resource "yandex_compute_instance" "lamp" {
  name        = "lamp-instance"
  hostname    = "lamp"
  platform_id = "standard-v1"
  boot_disk {
    initialize_params {
      image_id = var.lamp.image_id
      size     = var.lamp.disk_size
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }
  resources {
    cores         = var.lamp.cores
    memory        = var.lamp.memory
    core_fraction = var.lamp.core_fraction
  }

  metadata = {
    user-data = "${file("./cloud-init.yaml")}"
  }
}

resource "yandex_compute_instance_group" "group-nlb" {
  name               = "group-nlb"
  folder_id          = var.folder_id
  service_account_id = "${yandex_iam_service_account.ig-sa.id}"
  depends_on          = [yandex_resourcemanager_folder_iam_member.editor]
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = var.lamp.memory
      cores  = var.lamp.cores
    }
    boot_disk {
      initialize_params {
        image_id = var.lamp.image_id
      }
    }
    network_interface {
      network_id = "${yandex_vpc_network.base_network.id}"
      subnet_ids = ["${yandex_vpc_subnet.public.id}"]
      security_group_ids = ["${yandex_vpc_security_group.lamp-sg.id}"]
    }
    metadata = {
      user-data = "${file("./cloud-init.yaml")}"    }
    labels = {
      group = "group-nlb"
    }
  }
  scale_policy {
    fixed_scale {
      size = 3
    }
  }
  allocation_policy {
    zones = [var.default_zone]
  }
  deploy_policy {
    max_unavailable = 2
    max_expansion   = 1
  }
  load_balancer {
    target_group_name = "target-nlb"
  }
  health_check {
    interval = 15
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
    http_options {
      path = "/"
      port = 80
    }
  }
}

resource "yandex_lb_network_load_balancer" "nlb" {
  name = "nlb"
  listener {
    name = "nlb-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_compute_instance_group.group-nlb.load_balancer.0.target_group_id
    healthcheck {
      name = "http"
      interval = 10
      timeout = 5
      healthy_threshold = 5
      unhealthy_threshold = 2
      http_options {
        path = "/"
        port = 80
      }
    }
  }
}