#!/bin/bash


# AWS variables
export AWS_DEFAULT_REGION="eu-west-1"
export TF_VAR_node_instance_class="t2.large"
export TF_VAR_cluster_name="K8S"
export TF_VAR_route_table_association_count=2
export TF_VAR_subnet_count=2
export TF_VAR_autoscaling_desired_capacity=1
export TF_VAR_autoscaling_max_size=1
export TF_VAR_autoscaling_min_size=1