
resource "aws_autoscaling_group" "master-ap-northeast-2a-masters-kube-nalbam-com" {
  name                 = "master-ap-northeast-2a.masters.kube.nalbam.com"
  launch_configuration = "${aws_launch_configuration.master-ap-northeast-2a-masters-kube-nalbam-com.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.ap-northeast-2a-kube-nalbam-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "kube.nalbam.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-ap-northeast-2a.masters.kube.nalbam.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-ap-northeast-2a"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_group" "nodes-kube-nalbam-com" {
  name                 = "nodes.kube.nalbam.com"
  launch_configuration = "${aws_launch_configuration.nodes-kube-nalbam-com.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${aws_subnet.ap-northeast-2a-kube-nalbam-com.id}", "${aws_subnet.ap-northeast-2c-kube-nalbam-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "kube.nalbam.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.kube.nalbam.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_ebs_volume" "a-etcd-events-kube-nalbam-com" {
  availability_zone = "ap-northeast-2a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                        = "kube.nalbam.com"
    Name                                     = "a.etcd-events.kube.nalbam.com"
    "k8s.io/etcd/events"                     = "a/a"
    "k8s.io/role/master"                     = "1"
    "kubernetes.io/cluster/kube.nalbam.com" = "owned"
  }
}

resource "aws_ebs_volume" "a-etcd-main-kube-nalbam-com" {
  availability_zone = "ap-northeast-2a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                        = "kube.nalbam.com"
    Name                                     = "a.etcd-main.kube.nalbam.com"
    "k8s.io/etcd/main"                       = "a/a"
    "k8s.io/role/master"                     = "1"
    "kubernetes.io/cluster/kube.nalbam.com" = "owned"
  }
}

resource "aws_launch_configuration" "master-ap-northeast-2a-masters-kube-nalbam-com" {
  name_prefix                 = "master-ap-northeast-2a.masters.kube.nalbam.com-"
  image_id                    = "ami-2ad07c44"
  instance_type               = "t2.small"
  key_name                    = "${aws_key_pair.kubernetes-kube-nalbam-com-0f7cd3cfb8b7cd368820e05382fe0f12.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-kube-nalbam-com.id}"
  security_groups             = ["${aws_security_group.masters-kube-nalbam-com.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-ap-northeast-2a.masters.kube.nalbam.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_launch_configuration" "nodes-kube-nalbam-com" {
  name_prefix                 = "nodes.kube.nalbam.com-"
  image_id                    = "ami-2ad07c44"
  instance_type               = "t2.medium"
  key_name                    = "${aws_key_pair.kubernetes-kube-nalbam-com-0f7cd3cfb8b7cd368820e05382fe0f12.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-kube-nalbam-com.id}"
  security_groups             = ["${aws_security_group.nodes-kube-nalbam-com.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.kube.nalbam.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}
