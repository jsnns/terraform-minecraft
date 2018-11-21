provider "digitalocean" {
  token = "${var.do_token}"
}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "server" {
  image    = "ubuntu-18-04-x64"
  name     = "feed-the-beast"
  region   = "nyc1"
  size     = "s-2vcpu-4gb"
  ssh_keys = ["23556941"]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("~/.ssh/id_rsa")}"
    }

    inline = [
      "wget https://www.feed-the-beast.com/projects/ftb-revelation/files/2618046/download",
      "apt update -y",
      "apt install unzip openjdk-8-jre-headless -y",
      "unzip download",
      "rm download",
      "git clone https://${var.gitlab_username}:${var.gitlab_password}@gitlab.com/${var.gitlab_username}/mc-world-${var.world_name}.git /root/world",
      "crontab -l | { cat; echo \"* * * * * bash /root/world/push.sh \"; } | crontab -",
      "echo eula=true > /root/eula.txt",
      "bash /root/FTBInstall.sh",
    ]
  }
}

resource "digitalocean_floating_ip_assignment" "server_id" {
  ip_address = "159.203.157.148"
  droplet_id = "${digitalocean_droplet.server.id}"
}
