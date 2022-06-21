# instances

resource "yandex_compute_instance" "vm-nat" {
  name = "vm-nat"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-public.id
    nat        = true
    ip_address = "192.168.10.254"
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-public" {
  name = "vm-public"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-public.id
    nat        = true
    #ip_address = "192.168.10.02"
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}


resource "yandex_compute_instance" "vm-private" {
  name = "vm-private"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-private.id
    #ip_address = "192.168.20.02"
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}
