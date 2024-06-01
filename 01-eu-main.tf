# create a europe vpc network
resource "google_compute_network" "eu-vpc" {
  name                    = var.eu-vpc.vpc.name
  auto_create_subnetworks = false
}

# create an eu subnet
resource "google_compute_subnetwork" "eu-subnet" {
  name                     = var.eu-vpc.eu-subnet.name
  ip_cidr_range            = var.eu-vpc.eu-subnet.cidr
  region                   = var.eu-vpc.eu-subnet.region
  network                  = google_compute_network.eu-vpc.id
  private_ip_google_access = true
}

# create a firewall to allow http traffic in europe
resource "google_compute_firewall" "eu-firewall" {
  name    = var.eu-vpc.firewall
  network = google_compute_network.eu-vpc.id

  allow {
    protocol = "tcp"
    ports    = var.ports
  }
  target_tags = ["eu-http-server"]

  source_ranges = [var.eu-vpc.eu-subnet.cidr, var.us-vpc.us-east-subnet.cidr,
  var.us-vpc.us-west-subnet.cidr, var.asia-vpc.asia-subnet.cidr]
}

resource "google_compute_instance" "eu-instance" {
  name         = var.eu-vpc.subnet.instance_name
  machine_type = var.machine_types.linux.machine_type
  zone         = var.eu-vpc.subnet.zone

  boot_disk {
    initialize_params {
      image = var.machine_types.linux.image
      size  = 10
    }
    auto_delete = true
  }

  network_interface {
    network    = google_compute_network.eu-vpc.id
    subnetwork = google_compute_subnetwork.eu-subnet.id

    # No public IP allowed
    # access_config {
    #   // Ephemeral public IP
    # }
  }

  tags = ["eu-http-server"]

  metadata_startup_script = file("startup.sh")

}
