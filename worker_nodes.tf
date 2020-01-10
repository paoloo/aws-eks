resource "aws_launch_configuration" "this" {
  iam_instance_profile = aws_iam_instance_profile.eks-worker-instance-profile.name
  image_id             = data.aws_ami.eks-worker-ami.id
  instance_type        = var.worker_node_instance_size
  name_prefix          = "${var.cluster_name}-"
  security_groups      = [aws_security_group.eks-worker-nodes.id]
  user_data_base64     = "${base64encode(data.template_file.worker-user-data.rendered)}"
  key_name             = var.key_name
  root_block_device {
    delete_on_termination = var.worker_node_delete_disk_on_termination
    volume_size           = var.worker_node_disk_size
    volume_type           = var.worker_node_disk_type
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  desired_capacity     = var.worker_node_asg_configs["desired_capacity"]
  launch_configuration = aws_launch_configuration.this.id
  max_size             = var.worker_node_asg_configs["max_size"]
  min_size             = var.worker_node_asg_configs["min_size"]
  name                 = var.cluster_name
  vpc_zone_identifier  = data.aws_subnet_ids.private.ids

  dynamic "tag" {
    for_each = {
      for key, value in merge(
        {
          "Name" = var.cluster_name
        },
        {
          "k8s.io/cluster-autoscaler/enabled" = "true"
        },
        {
          "kubernetes.io/cluster/${var.cluster_name}" = "owned"
        },
        var.additional_tags
      ) :
      key => value
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
