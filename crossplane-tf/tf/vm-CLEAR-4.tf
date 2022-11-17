      resource "nutanix_virtual_machine" "vm-CLEAR-4" {
        name                 = "vm-CLEAR-4"
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
