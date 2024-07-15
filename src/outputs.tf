# output "public" {
#   value = "${yandex_compute_instance.public_instance.name} - ${yandex_compute_instance.public_instance.network_interface.0.ip_address}(${yandex_compute_instance.public_instance.network_interface.0.nat_ip_address})"
# }

# output "private" {
#   value = "${yandex_compute_instance.private_instance.name} - ${yandex_compute_instance.private_instance.network_interface.0.ip_address}(${yandex_compute_instance.private_instance.network_interface.0.nat_ip_address})"
# }

output "external_ip_address_public" {
  value = yandex_compute_instance.public_instance.network_interface.0.nat_ip_address
}
output "external_ip_address_nat" {
  value = yandex_compute_instance.nat_instance.network_interface.0.nat_ip_address
}
output "internal_ip_address_private" {
  value = yandex_compute_instance.private_instance.network_interface.0.ip_address
}
output "ipaddress_group-nlb" {
  value = yandex_compute_instance_group.group-nlb.instances[*].network_interface[0].ip_address
}
# output "nlb_address" {
#   value = yandex_lb_network_load_balancer.nlb.*.external_address_spec[0].*.address
# }
output "picture_url" {
  value = "https://${yandex_storage_bucket.zhivarev.bucket_domain_name}/${yandex_storage_object.my-picture.key}"
}
