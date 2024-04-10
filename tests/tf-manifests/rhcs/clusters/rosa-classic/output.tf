output "cluster_id" {
  value = module.rhcs.cluster_id
}

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_version" {
  value = var.openshift_version
}

output "additional_compute_security_groups" {
  value = var.additional_compute_security_groups
}

output "additional_infra_security_groups" {
  value = var.additional_infra_security_groups
}

output "additional_control_plane_security_groups" {
  value = var.additional_control_plane_security_groups
}
