#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'

yum install -y wget git python-pip jq
pip install -U pip
pip install ansible ansible==2.6

cat << EOF >> /etc/environment
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="`curl http://169.254.169.254/latest/meta-data/instance-id`.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT="${route53_sub_domain}"
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"
export INSTANCE_ID="`curl http://169.254.169.254/latest/meta-data/instance-id`"
export REGION="${region}"
EOF
## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="`curl http://169.254.169.254/latest/meta-data/instance-id`.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT="${route53_sub_domain}"
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"
export INSTANCE_ID="`curl http://169.254.169.254/latest/meta-data/instance-id`"
export REGION="${region}"

cat << EOF > ~/requirements.yml
---
##
# ${app_name}
##

- name: bootstrap
  src: https://github.com/ministryofjustice/hmpps-bootstrap
  version: centos
- name: users
  src: singleplatform-eng.users
- name: "${app_bootstrap_name}"
  src: "${app_bootstrap_src}"
  version: "${app_bootstrap_version}"

EOF

/usr/bin/curl -o ~/users.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml

/usr/bin/curl -o ~/nomis.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-env-configs/master/${route53_sub_domain}/ansible/group_vars/all.yml

cat << EOF > ~/vars.yml
---

region: "${region}"
cldwatch_log_group: "${cldwatch_log_group}"

# Artefact locations
s3_dependencies_bucket: "${s3_dependencies_bucket}"

# Server/WebLogic config
domain_name: "${domain_name}"
server_name: "${server_name}"
jvm_mem_args: "${jvm_mem_args}"
server_params: "${server_params}"
weblogic_admin_username: "${weblogic_admin_username}"
server_listen_address: "${server_listen_address}"
server_listen_port: "${server_listen_port}"

# Database
setup_datasources: "${setup_datasources}"
primary_db_host: "${primary_db_host}"
database_url: "${database_url}"

# NOMIS
nomis_url: "${nomis_url}"
nomis_client_id: "${nomis_client_id}"
nomis_client_secret: "${nomis_client_secret}"

# For user_update cron
remote_user_filename: "${bastion_inventory}"

EOF

cat << EOF > ~/bootstrap.yml
---

- hosts: localhost
  vars_files:
   - "{{ playbook_dir }}/vars.yml"
   - "{{ playbook_dir }}/users.yml"
   - "{{ playbook_dir }}/nomis.yml"
  roles:
     - bootstrap
     - users
     - "{{ playbook_dir }}/.ansible/roles/${app_bootstrap_name}/roles/${app_bootstrap_initial_role}"
EOF

# get ssm parameters
PARAM=$(aws ssm get-parameters \
--region eu-west-2 \
--with-decryption --name \
"/${environment_name}/${project_name}/weblogic/${app_name}-domain/weblogic_admin_password" \
"/${environment_name}/${project_name}/nomis-database/db/nomis_pool_password" \
--query Parameters)

# set parameter values
weblogic_admin_password="$(echo $PARAM | jq '.[] | select(.Name | test("weblogic_admin_password")) | .Value' --raw-output)"
database_password="$(echo $PARAM | jq '.[] | select(.Name | test("nomis_pool_password")) | .Value' --raw-output)"
usermanagement_secret="$(echo $PARAM | jq '.[] | select(.Name | test("nomis_secret")) | .Value' --raw-output)"

export ANSIBLE_LOG_PATH=$HOME/.ansible.log

ansible-galaxy install -f -r ~/requirements.yml
CONFIGURE_SWAP=true ansible-playbook ~/bootstrap.yml \
--extra-vars "{\
'instance_id':'$INSTANCE_ID', \
'weblogic_admin_password':'$weblogic_admin_password', \
'database_password':'$database_password', \
}"
