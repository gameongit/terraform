# For creating a nodebalancer

provider "linode" {
    token = "${var.token}"
}


resource "linode_nodebalancer" "example-nodebalancer" {
    label = "examplenodebalancer"
    region = "${var.region}"
}

resource "linode_nodebalancer_config" "example-nodebalancer-config" {
    nodebalancer_id = "${linode_nodebalancer.example-nodebalancer.id}"
    port = 80
    protocol = "http"
    check = "http_body"
    check_path = "/healthcheck/"
    check_body = "healthcheck"
    check_attempts = 30
    check_timeout = 25
    check_interval = 30
    stickiness = "http_cookie"
    algorithm = "roundrobin"
}

resource "linode_nodebalancer_node" "example-nodebalancer-node" {
    count = "${var.node_count}"
    nodebalancer_id = "${linode_nodebalancer.example-nodebalancer.id}"
    config_id = "${linode_nodebalancer_config.example-nodebalancer-config.id}"
    label = "example-node-${count.index + 1}"
    address = "${element(linode_instance.example-instance.*.private_ip_address, count.index)}:80"
    mode = "accept"
}


