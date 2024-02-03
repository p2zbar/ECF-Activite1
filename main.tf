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

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = var.cluster_identifier
  engine                  = "docdb"
  engine_version          = var.engine_version
  master_username         = var.master_username
  master_password         = var.master_password
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]
}

resource "aws_docdb_cluster_instance" "docdb_instances" {
  count              = var.instance_count
  identifier         = "${var.cluster_identifier}-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = var.instance_class
  engine             = "docdb"
}

resource "aws_cloudwatch_dashboard" "monitoring_docdb_cluster" {
  dashboard_name = "ApplicationMetricsDashboard"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          ["Custom/Namespace", "WriteOperations", "Application", "MyApp"],
          ["Custom/Namespace", "ReadOperations", "Application", "MyApp"],
          ["Custom/Namespace", "DeleteOperations", "Application", "MyApp"]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "${var.region}",
        "stat": "Sum",
        "period": 300,
        "title": "Application Operations over 300s"
      }
    },
    {
      "type": "text",
      "x": 0,
      "y": 7,
      "width": 3,
      "height": 3,
      "properties": {
        "markdown": "This dashboard provides an overview of application operations."
      }
    }
  ]
}
EOF
}