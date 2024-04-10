terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.0"
    }
    rhcs = {
      version = ">= 1.0.1"
      source  = "terraform.local/local/rhcs"
    }
  }
}

provider "rhcs" {
  # url = var.url
  url = "https://api.stage.openshift.com/"
}
provider "aws" {
  region = var.aws_region
}
locals {
  versionfilter = var.openshift_version == null ? "" : " and id like '%${var.openshift_version}%'"
}

data "rhcs_versions" "version" {
  search = "enabled='t' and rosa_enabled='t' and channel_group='${var.channel_group}'${local.versionfilter}"
  order  = "id"
}
locals {
  version = data.rhcs_versions.version.items[0].name
}

data "aws_caller_identity" "current" {
}

module "rhcs" {
  source            = "../../../../../../terraform-rhcs-rosa-classic"
  openshift_version = local.version
  cluster_name      = var.cluster_name

  create_account_roles  = true
  create_operator_roles = true
  create_oidc           = true
  account_role_prefix   = var.account_role_prefix
  operator_role_prefix  = var.operator_role_prefix
  oidc_config_id        = var.oidc_config_id
  path                  = coalesce(var.path, "/")

  aws_subnet_ids = var.aws_subnet_ids != null ? var.aws_subnet_ids : []
  # aws_availability_zones   = var.aws_availability_zones != null ? var.aws_availability_zones : slice(data.aws_availability_zones.zones.names, 0, 3)
  aws_availability_zones   = var.aws_availability_zones != null ? var.aws_availability_zones : []
  replicas                 = var.replicas
  ec2_metadata_http_tokens = var.aws_http_tokens_state
  autoscaling_enabled      = var.autoscaling.autoscaling_enabled
  min_replicas             = var.autoscaling.min_replicas
  max_replicas             = var.autoscaling.max_replicas

  aws_private_link = var.private_link
  private          = var.private

  compute_machine_type        = var.compute_machine_type
  default_mp_labels           = var.default_mp_labels
  disable_scp_checks          = var.disable_scp_checks
  disable_workload_monitoring = var.disable_workload_monitoring
  etcd_encryption             = var.etcd_encryption
  fips                        = var.fips
  host_prefix                 = var.host_prefix
  kms_key_arn                 = var.kms_key_arn
  machine_cidr                = var.machine_cidr
  service_cidr                = var.service_cidr
  pod_cidr                    = var.pod_cidr

  multi_az = var.multi_az
  properties = merge(
    {
      rosa_creator_arn = data.aws_caller_identity.current.arn
    },
    var.custom_properties
  )
  tags                                            = var.tags
  worker_disk_size                                = var.worker_disk_size
  aws_additional_compute_security_group_ids       = var.additional_compute_security_groups
  aws_additional_infra_security_group_ids         = var.additional_infra_security_groups
  aws_additional_control_plane_security_group_ids = var.additional_control_plane_security_groups
  destroy_timeout                                 = 120
  upgrade_acknowledgements_for                    = var.upgrade_acknowledgements_for

  # channel_group      = var.channel_group
  # cloud_region       = var.aws_region
  # aws_account_id     = data.aws_caller_identity.current.account_id
  # base_dns_domain                                 = var.base_dns_domain
  # private_hosted_zone                             = var.private_hosted_zone

  # Admin credential
  admin_credentials_username = var.admin_credentials != null ? var.admin_credentials.username : null
  admin_credentials_password = var.admin_credentials != null ? var.admin_credentials.password : null

  # Proxy settings
  http_proxy              = var.proxy != null ? var.proxy.http_proxy : null
  https_proxy             = var.proxy != null ? var.proxy.https_proxy : null
  no_proxy                = var.proxy != null ? var.proxy.no_proxy : null
  additional_trust_bundle = var.proxy != null ? var.proxy.additional_trust_bundle : null

  wait_for_create_complete = true
}
