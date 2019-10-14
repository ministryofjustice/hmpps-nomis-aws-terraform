# Weblogic tier nomis

locals {
  # Override default values
  ansible_vars = "${merge(var.default_ansible_vars, var.ansible_vars)}"
}

module "nomis" {
  # source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//weblogic-admin-only"
  source               = "../../modules/weblogic-admin-only"
  tier_name            = "nomis"
  ami_id               = "${data.aws_ami.centos_wls.id}"
  instance_type        = "${var.instance_type_weblogic}"
  instance_count       = "${var.instance_count_weblogic_nomis}"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile = "${data.terraform_remote_state.key_profile.instance_profile_ec2_id}"

  instance_security_groups = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.nomis_security_groups.sg_weblogic_nomis_instances_id}",
    "${data.terraform_remote_state.nomis_security_groups.sg_common_out_id}",
  ]
  lb_security_groups = [
    "${data.terraform_remote_state.nomis_security_groups.sg_weblogic_nomis_lb_id}"
  ]

  public_subnets = "${list(
    data.terraform_remote_state.vpc.vpc_public-subnet-az1,
    data.terraform_remote_state.vpc.vpc_public-subnet-az2,
    data.terraform_remote_state.vpc.vpc_public-subnet-az3,
  )}"

  private_subnets = "${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3,
  )}"

  tags                         = "${var.tags}"
  environment_name             = "${data.terraform_remote_state.vpc.environment_name}"
  bastion_inventory            = "${data.terraform_remote_state.vpc.bastion_inventory}"
  project_name                 = "${var.project_name}"
  environment_identifier       = "${var.environment_identifier}"
  short_environment_identifier = "${var.short_environment_identifier}"
  short_environment_name       = "${var.short_environment_name}"
  environment_type             = "${var.environment_type}"
  region                       = "${var.region}"
  vpc_id                       = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_account_id               = "${data.terraform_remote_state.vpc.vpc_account_id}"
  kms_key_id                   = "${data.terraform_remote_state.key_profile.kms_arn_app}"
  public_zone_id               = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_zone_id              = "${data.terraform_remote_state.vpc.private_zone_id}"
  private_domain               = "${data.terraform_remote_state.vpc.private_zone_name}"
  certificate_arn              = "${data.aws_acm_certificate.cert.arn}"
  weblogic_health_check_path   = "nomis-war/nomis/JSP/healthcheck.jsp"
  weblogic_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  weblogic_tls_port            = "${var.weblogic_domain_ports["weblogic_tls_port"]}"
  activemq_port                = "${var.weblogic_domain_ports["activemq_port"]}"
  activemq_enabled             = "false"

  app_bootstrap_name         = "hmpps-nomis-bootstrap"
  app_bootstrap_src          = "https://github.com/ministryofjustice/hmpps-nomis-bootstrap"
  app_bootstrap_version      = "creation"
  app_bootstrap_initial_role = "nomis"

  ansible_vars = {
    cldwatch_log_group       = "${var.environment_identifier}/weblogic-nomis"

    # Artefact locations
    s3_dependencies_bucket   = "${substr("${var.dependencies_bucket_arn}", 13, -1)}"

    # Server/WebLogic config
    domain_name              = "${local.ansible_vars["domain_name"]}"
    server_name              = "${local.ansible_vars["server_name"]}"
    jvm_mem_args             = "${local.ansible_vars["jvm_mem_args"]}"
    server_params            = "${local.ansible_vars["jvm_mem_args"]} -XX:MaxPermSize=256m"
    weblogic_admin_username  = "${local.ansible_vars["weblogic_admin_username"]}"
    server_listen_address    = "${local.ansible_vars["server_listen_address"]}"
    server_listen_port       = "${var.weblogic_domain_ports["weblogic_port"]}"

    # Database
    setup_datasources        = "${local.ansible_vars["setup_datasources"]}"
    primary_db_host          = "${data.terraform_remote_state.database_failover.public_fqdn_nomis_db_1}"
    database_url             = "${data.terraform_remote_state.database_failover.jdbc_failover_url}"
    database_min_pool_size   = "${local.ansible_vars["database_min_pool_size"]}"
    database_max_pool_size   = "${local.ansible_vars["database_max_pool_size"]}"

    # NOMIS
    nomis_url                = "${local.ansible_vars["nomis_url"]}"
    nomis_client_id          = "${local.ansible_vars["nomis_client_id"]}"
    nomis_client_secret      = "${local.ansible_vars["nomis_client_secret"]}"

    ## the following are retrieved from SSM Parameter Store
    ## weblogic_admin_password  = "/${environment_name}/nomis/weblogic/${app_name}-domain/weblogic_admin_password"
    ## database_password        = "/${environment_name}/${project}/nomis-database/db/nomis_pool_password"
  }
}

output "ami_nomis_wls" {
  value = "${data.aws_ami.centos_wls.id} - ${data.aws_ami.centos_wls.name}"
}

output "private_fqdn_nomis_wls_internal_alb" {
  value = "${module.nomis.private_fqdn_internal_alb}"
}

output "newtech_webfrontend_target_group_arn" {
  value = "${module.nomis.newtech_webfrontend_targetgroup_arn}"
}
