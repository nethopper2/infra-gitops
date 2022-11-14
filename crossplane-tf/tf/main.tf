      # // Outputs are written to the connection secret.
      # output "url" {
      #   value       = random_id.example.byte_length
      # }
      # resource "random_id" "example" {
      #   byte_length = 4
      # }

      // Outputs are written to the connection secret.
      output "image-name" {
        value       = nutanix_image.image.name
      }

      data "nutanix_cluster" "cluster" {
        name = "nh-devops"
      }

      provider "nutanix" {
        username     = "admin"
        password     = "Nethopper123$"
        endpoint     = "192.168.1.208"
        insecure     = true
        wait_timeout = 60
      }

      resource "nutanix_image" "image" {
        # name        = "ubuntu-20.04.2.0-desktop-amd64.iso"
        name        = "ubuntu-20.04.5-desktop-amd64.iso"
        # description = "Ubuntu 20.04 LTS"
        # source_uri = "https://releases.ubuntu.com/focal/ubuntu-20.04.5-desktop-amd64.iso"
        # id = "f7542282-97a2-4bf5-ade9-c4a34e3ff7d1"
        # metadata = {
        #   uuid = "f7542282-97a2-4bf5-ade9-c4a34e3ff7d1"
        # }
        # id = "28ccb338-f572-4088-9bb7-fd7e4ede8282"
      }

      resource "nutanix_virtual_machine" "vm" {
        name                 = "MyVM from the Terraform Nutanix Provider"
        cluster_uuid         = data.nutanix_cluster.cluster.id
        num_vcpus_per_socket = "2"
        num_sockets          = "1"
        memory_size_mib      = 1024

        disk_list {
          data_source_reference = {
            kind = "image"
            uuid = nutanix_image.image.id
          }
        }

        disk_list {
          disk_size_bytes = 10 * 1024 * 1024 * 1024
          device_properties {
            device_type = "DISK"
            disk_address = {
              "adapter_type" = "SCSI"
              "device_index" = "1"
            }
          }
        }
        nic_list {
          subnet_uuid = "60c32389-b434-47a8-9926-825c3ab91ec2"
        }
      }