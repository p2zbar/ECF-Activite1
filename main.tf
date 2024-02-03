provider "aws" {
  region = var.region
}

resource "aws_emr_cluster" "spark_cluster" {
  name          = var.cluster_name
  release_label = var.release_label 
  applications  = var.applications

  ec2_attributes {
    subnet_id                         = var.subnet_id
    instance_profile                  = var.instance_profile
    emr_managed_master_security_group = var.emr_managed_master_security_group
    emr_managed_slave_security_group  = var.emr_managed_slave_security_group
    key_name = var.key_name
  }

  service_role = var.service_role
  autoscaling_role = var.autoscaling_role

  master_instance_group {
    instance_type  = var.master_instance_type
    instance_count = var.master_instance_count
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = var.core_instance_count
  }
}
