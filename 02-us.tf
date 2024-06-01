# create a us vpc network
resource "google_compute_network" "us-vpc" {
  name                    = var.us-vpc.vpc.name
  auto_create_subnetworks = false
}

# create an us-east subnet
resource "google_compute_subnetwork" "us-east-subnet" {
  name                     = var.us-vpc.us-east-subnet.name
  ip_cidr_range            = var.us-vpc.us-east-subnet.cidr
  region                   = var.us-vpc.us-east-subnet.region
  network                  = google_compute_network.us-vpc.id
  private_ip_google_access = true
}

# create an us-west subnet
resource "google_compute_subnetwork" "us-west-subnet" {
  name                     = var.us-vpc.us-west-subnet.name
  ip_cidr_range            = var.us-vpc.us-west-subnet.cidr
  region                   = var.us-vpc.us-west-subnet.region
  network                  = google_compute_network.us-vpc.id
  private_ip_google_access = true
}

# create a firewall to allow http from us to europe
resource "google_compute_firewall" "us-firewall" {
  name    = var.us-vpc.vpc.firewall
  network = google_compute_network.us-vpc.id

  allow {
    protocol = "tcp"
    ports    = var.ports
  }

  target_tags   = ["us-http-server", "iap-ssh-allowed"]
  source_ranges = ["0.0.0.0/0", "35.235.240.0/20"]
}

# create a us-east instance
resource "google_compute_instance" "us-east-instance" {
  name         = var.us-vpc.us-east-subnet.instance_name
  machine_type = var.machine_types.linux.machine_type
  zone         = var.us-vpc.us-east-subnet.zone

  boot_disk {
    initialize_params {
      image = var.machine_types.linux.image
      size  = 10
    }
    auto_delete = true
  }

  network_interface {
    network    = google_compute_network.us-vpc.id
    subnetwork = google_compute_subnetwork.us-east-subnet.id

    # No public IP allowed
    # access_config {
    #   // Ephemeral public IP
    # }
  }

  tags = ["us-http-server", "iap-ssh-allowed"]
  # no script needed for this instance
  # metadata_startup_script = file("startup.sh")

}

# create a us-west instance
resource "google_compute_instance" "us-west-instance" {
  name         = var.us-vpc.us-west-subnet.instance_name
  machine_type = var.machine_types.linux.machine_type
  zone         = var.us-vpc.us-west-subnet.zone

  boot_disk {
    initialize_params {
      image = var.machine_types.linux.image
      size  = 10
    }
    auto_delete = true
  }

  network_interface {
    network    = google_compute_network.us-vpc.id
    subnetwork = google_compute_subnetwork.us-west-subnet.id

    # No public IP allowed
    # access_config {
    #   // Ephemeral public IP
    # }
  }

  tags = ["us-http-server", "iap-ssh-allowed"]
  # no script needed for this instance
  # metadata_startup_script = file("startup.sh")

}
