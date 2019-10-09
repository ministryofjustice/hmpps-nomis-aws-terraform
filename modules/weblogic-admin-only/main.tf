#TODO: ASG for managed should nightly cycle boxes

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data/user_data.${var.tier_name}.sh")}"

  vars {
    project_name                  = "${var.project_name}"
    env_identifier                = "${var.environment_identifier}"
    short_env_identifier          = "${var.short_environment_identifier}"
    region                        = "${var.region}"
    app_name                      = "${var.tier_name}"
    route53_sub_domain            = "${var.environment_name}"
    environment_name              = "${var.environment_name}"
    private_domain                = "${var.private_domain}"
    account_id                    = "${var.vpc_account_id}"
    bastion_inventory             = "${var.bastion_inventory}"
    app_bootstrap_name            = "${var.app_bootstrap_name}"
    app_bootstrap_src             = "${var.app_bootstrap_src}"
    app_bootstrap_version         = "${var.app_bootstrap_version}"
    app_bootstrap_initial_role    = "${var.app_bootstrap_initial_role}"
    app_bootstrap_secondary_role  = "${var.app_bootstrap_secondary_role}"
    app_bootstrap_tertiary_role   = "${var.app_bootstrap_tertiary_role}"

    cldwatch_log_group       = "${var.ansible_vars["cldwatch_log_group"]}"

    # Artefact locations
    s3_dependencies_bucket   = "${var.ansible_vars["s3_dependencies_bucket"]}"

    # Server/WebLogic config
    domain_name              = "${var.ansible_vars["domain_name"]}"
    server_name              = "${var.ansible_vars["server_name"]}"
    jvm_mem_args             = "${var.ansible_vars["jvm_mem_args"]}"
    server_params            = "${var.ansible_vars["server_params"]}"
    weblogic_admin_username  = "${var.ansible_vars["weblogic_admin_username"]}"
    server_listen_address    = "${var.ansible_vars["server_listen_address"]}"
    server_listen_port       = "${var.ansible_vars["server_listen_port"]}"

    # Database
    setup_datasources        = "${var.ansible_vars["setup_datasources"]}"
    primary_db_host          = "${var.ansible_vars["primary_db_host"]}"
    database_url             = "${var.ansible_vars["database_url"]}"

    # NOMIS
    nomis_url                = "${var.ansible_vars["nomis_url"]}"
    nomis_client_id          = "${var.ansible_vars["nomis_client_id"]}"
    nomis_client_secret      = "${var.ansible_vars["nomis_client_secret"]}"
  }
}
