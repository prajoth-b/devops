resource "null_resource" "provision" {
  provisioner "local-exec" {
    command = "echo ${timestamp()} >> /tmp/times.txt"
  }
}
