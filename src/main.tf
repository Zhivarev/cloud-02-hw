// Создание сервисного аккаунта
resource "yandex_iam_service_account" "bucket" {
  name = "bucket"
}

// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.bucket.id}"
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.bucket.id
  description        = "static access key for object storage"
}

// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "zhivarev" {
  access_key            = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key            = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket                = "zhivarev-12072024"
  max_size              = 1073741824 # 1 Gb
  anonymous_access_flags {
    read        = true
    list        = true
    config_read = false
  }
}

# Add picture in the bucket
resource "yandex_storage_object" "my-picture" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.zhivarev.id
  key        = "img.png"
  source     = "../img/img.png"
}

resource "yandex_iam_service_account" "ig-sa" {
  name        = "ig-sa"
  description = "Сервисный аккаунт для управления группой ВМ."
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id  = var.folder_id
  role       = "editor"
  member     = "serviceAccount:${yandex_iam_service_account.ig-sa.id}"
  depends_on = [
    yandex_iam_service_account.ig-sa,
  ]
}

# resource "yandex_compute_instance_group" "ig-1" {
#   name                = "fixed-ig"
#   folder_id           = var.folder_id
#   service_account_id  = "${yandex_iam_service_account.ig-sa.id}"
#   deletion_protection = false
#   depends_on          = [yandex_resourcemanager_folder_iam_member.editor]
#   instance_template {
#     platform_id = "standard-v1"
#     resources {
#       memory = var.vm_base.memory
#       cores  = var.vm_base.cores
#     }

#     boot_disk {
#       initialize_params {
#         image_id = var.vm_base.image_id
#       }
#     }

#     network_interface {
#       network_id         = "${yandex_vpc_network.base_network.id}"
#       subnet_ids         = ["${yandex_vpc_subnet.public.id}"]
#       security_group_ids = ["${yandex_vpc_security_group.lamp-sg.id}"]
#     }

#     metadata = {
#       user-data = "${file("./cloud-init.yaml")}"
#     }
#   }

#   scale_policy {
#     fixed_scale {
#       size = 3
#     }
#   }

#   allocation_policy {
#     zones = [var.default_zone]
#   }

#   deploy_policy {
#     max_unavailable = 2
#     max_expansion   = 1
#   }
# }
