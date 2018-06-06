
output "cluster_name" {
  value = "kube.nalbam.com"
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-kube-nalbam-com.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-kube-nalbam-com.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-kube-nalbam-com.name}"
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-kube-nalbam-com.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.ap-northeast-2a-kube-nalbam-com.id}", "${aws_subnet.ap-northeast-2c-kube-nalbam-com.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-kube-nalbam-com.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-kube-nalbam-com.name}"
}

output "region" {
  value = "ap-northeast-2"
}

output "vpc_id" {
  value = "${aws_vpc.kube-nalbam-com.id}"
}
