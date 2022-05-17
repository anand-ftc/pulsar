/*
data  "template_file" "k8s" {
    template = "${file("./templates/k8s.tpl")}"
    vars {
        k8s_master_name = "${join("\n", azurerm_virtual_machine.k8s-master.*.name)}"
    }
}

resource "local_file" "k8s_file" {
  content  = "${data.template_file.k8s.rendered}"
  filename = "./inventory/k8s-host"
}
*/


/****************
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/try1/i3.tpl", { 
    #   content = tomap({
       brokers = "${join("\n", tomap({ public = aws_instance.broker.*.public_ip, private = aws_instance.broker.*.private_ip }) )}"
    #   zookeepers = aws_instance.zookeeper.*.public_ip
    #   bookies = aws_instance.bookie.*.public_ip
    #   proxies = aws_instance.proxy.*.public_ip
    #   test_clients = aws_instance.test_client.*.public_ip
    # })
    }
  )
  filename = "${path.module}/try1/hosts.cfg"
}
*/
resource "local_file" "ansible_hosts" {
#   count   = "${var.customer_plan == "micro" ? "1" : "0"}"
# https://gist.github.com/hectorcanto/71f732dc02541e265888e924047d47ed
  content = "[broker]\n${join("\n",
            formatlist(
              "%s id=%s private_ip=%s",
              aws_instance.broker.*.public_ip,
              aws_instance.broker.*.id,
              aws_instance.broker.*.private_ip
            )
            )}\n\n[zookeeper]\n${join("\n",
            formatlist(
              "%s id=%s private_ip=%s",
              aws_instance.zookeeper.*.public_ip,
              aws_instance.zookeeper.*.id,
              aws_instance.zookeeper.*.private_ip
            )
            )}\n\n[bookie]\n${join("\n",
            formatlist(
              "%s id=%s private_ip=%s",
              aws_instance.bookie.*.public_ip,
              aws_instance.bookie.*.id,
              aws_instance.bookie.*.private_ip
            )
            )}\n\n[proxy]\n${join("\n",
            formatlist(
              "%s id=%s private_ip=%s",
              aws_instance.proxy.*.public_ip,
              aws_instance.proxy.*.id,
              aws_instance.proxy.*.private_ip
            )
            )}\n\n[all:vars]\npulsar_service_url=pulsar://${aws_elb.default.dns_name}:6650\ndns_name=${aws_elb.default.dns_name}\npulsar_web_url=http://${aws_elb.default.dns_name}:8080\npulsar_ssh_host=${aws_instance.proxy.0.public_ip}"

  filename = "${path.module}/hosts.cfg"


}