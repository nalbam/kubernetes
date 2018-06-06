
resource "aws_vpc" "kube-nalbam-com" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster                        = "kube.nalbam.com"
    Name                                     = "kube.nalbam.com"
    "kubernetes.io/cluster/kube.nalbam.com" = "owned"
  }
}

resource "aws_subnet" "ap-northeast-2a-kube-nalbam-com" {
  vpc_id            = "${aws_vpc.kube-nalbam-com.id}"
  cidr_block        = "10.20.32.0/19"
  availability_zone = "ap-northeast-2a"

  tags = {
    KubernetesCluster                        = "kube.nalbam.com"
    Name                                     = "ap-northeast-2a.kube.nalbam.com"
    SubnetType                               = "Public"
    "kubernetes.io/cluster/kube.nalbam.com" = "owned"
    "kubernetes.io/role/elb"                 = "1"
  }
}

resource "aws_subnet" "ap-northeast-2c-kube-nalbam-com" {
  vpc_id            = "${aws_vpc.kube-nalbam-com.id}"
  cidr_block        = "10.20.64.0/19"
  availability_zone = "ap-northeast-2c"

  tags = {
    KubernetesCluster                        = "kube.nalbam.com"
    Name                                     = "ap-northeast-2c.kube.nalbam.com"
    SubnetType                               = "Public"
    "kubernetes.io/cluster/kube.nalbam.com" = "owned"
    "kubernetes.io/role/elb"                 = "1"
  }
}

resource "aws_internet_gateway" "kube-nalbam-com" {
  vpc_id = "${aws_vpc.kube-nalbam-com.id}"

  tags = {
    KubernetesCluster                        = "kube.nalbam.com"
    Name                                     = "kube.nalbam.com"
    "kubernetes.io/cluster/kube.nalbam.com" = "owned"
  }
}

resource "aws_route_table" "kube-nalbam-com" {
  vpc_id = "${aws_vpc.kube-nalbam-com.id}"

  tags = {
    KubernetesCluster                        = "kube.nalbam.com"
    Name                                     = "kube.nalbam.com"
    "kubernetes.io/cluster/kube.nalbam.com" = "owned"
    "kubernetes.io/kops/role"                = "public"
  }
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.kube-nalbam-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.kube-nalbam-com.id}"
}

resource "aws_route_table_association" "ap-northeast-2a-kube-nalbam-com" {
  subnet_id      = "${aws_subnet.ap-northeast-2a-kube-nalbam-com.id}"
  route_table_id = "${aws_route_table.kube-nalbam-com.id}"
}

resource "aws_route_table_association" "ap-northeast-2c-kube-nalbam-com" {
  subnet_id      = "${aws_subnet.ap-northeast-2c-kube-nalbam-com.id}"
  route_table_id = "${aws_route_table.kube-nalbam-com.id}"
}

resource "aws_vpc_dhcp_options" "kube-nalbam-com" {
  domain_name         = "ap-northeast-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster                        = "kube.nalbam.com"
    Name                                     = "kube.nalbam.com"
    "kubernetes.io/cluster/kube.nalbam.com" = "owned"
  }
}

resource "aws_vpc_dhcp_options_association" "kube-nalbam-com" {
  vpc_id          = "${aws_vpc.kube-nalbam-com.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.kube-nalbam-com.id}"
}
