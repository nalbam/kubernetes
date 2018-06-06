
resource "aws_iam_role" "masters-kube-nalbam-com" {
  name               = "masters.kube.nalbam.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.kube.nalbam.com_policy")}"
}

resource "aws_iam_role" "nodes-kube-nalbam-com" {
  name               = "nodes.kube.nalbam.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.kube.nalbam.com_policy")}"
}

resource "aws_iam_instance_profile" "masters-kube-nalbam-com" {
  name = "masters.kube.nalbam.com"
  role = "${aws_iam_role.masters-kube-nalbam-com.name}"
}

resource "aws_iam_instance_profile" "nodes-kube-nalbam-com" {
  name = "nodes.kube.nalbam.com"
  role = "${aws_iam_role.nodes-kube-nalbam-com.name}"
}

resource "aws_iam_role_policy" "masters-kube-nalbam-com" {
  name   = "masters.kube.nalbam.com"
  role   = "${aws_iam_role.masters-kube-nalbam-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.kube.nalbam.com_policy")}"
}

resource "aws_iam_role_policy" "nodes-kube-nalbam-com" {
  name   = "nodes.kube.nalbam.com"
  role   = "${aws_iam_role.nodes-kube-nalbam-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.kube.nalbam.com_policy")}"
}

resource "aws_key_pair" "kubernetes-kube-nalbam-com-0f7cd3cfb8b7cd368820e05382fe0f12" {
  key_name   = "kubernetes.kube.nalbam.com-0f:7c:d3:cf:b8:b7:cd:36:88:20:e0:53:82:fe:0f:12"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.kube.nalbam.com-0f7cd3cfb8b7cd368820e05382fe0f12_public_key")}"
}
