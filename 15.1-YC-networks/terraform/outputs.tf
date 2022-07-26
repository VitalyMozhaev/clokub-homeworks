# outputs

output "internal-ip-vm-nat" {
  value = yandex_compute_instance.vm-nat.network_interface.0.ip_address
}

output "internal-ip-vm-public" {
  value = yandex_compute_instance.vm-public.network_interface.0.ip_address
}

output "external-ip-vm-public" {
  value = yandex_compute_instance.vm-public.network_interface.0.nat_ip_address
}

output "internal-ip-vm-private" {
  value = yandex_compute_instance.vm-private.network_interface.0.ip_address
}

output "external-ip-vm-private" {
  value = yandex_compute_instance.vm-private.network_interface.0.nat_ip_address
}
