# nomis-db-in.tf

################################################################################
## nomis_db_in
################################################################################
resource "aws_security_group" "nomis_db_in" {
  name        = "${var.environment_name}-nomis-db-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Nomis database in"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-nomis-db-in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_nomis_db_in_id" {
  value = "${aws_security_group.nomis_db_in.id}"
}

resource "aws_security_group_rule" "weblogic_nomis_admin_db_in" {
  security_group_id        = "${aws_security_group.nomis_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.weblogic_nomis_instances.id}"
  description              = "wls nomis instances in"
}

resource "aws_security_group_rule" "db_to_db_in" {
  security_group_id = "${aws_security_group.nomis_db_in.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "1521"
  to_port           = "1521"
  self              = true
  description       = "Inter db comms"
}

resource "aws_security_group_rule" "db_to_db_ssh_in" {
  security_group_id = "${aws_security_group.nomis_db_in.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  self              = true
  description       = "Inter db ssh comms"
}

resource "aws_security_group_rule" "eng_rman_catalog_db_in" {
  security_group_id        = "${aws_security_group.nomis_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${data.terraform_remote_state.ora_db_op_security_groups.sg_map_ids.rman_catalog}"
  description              = "RMAN Catalog in"
}

