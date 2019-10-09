# nomis-db-out.tf

################################################################################
## nomis_db_out
################################################################################
resource "aws_security_group" "nomis_db_out" {
  name        = "${var.environment_name}-nomis-db-out"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "nomis database out"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-nomis-db-out", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_nomis_db_out_id" {
  value = "${aws_security_group.nomis_db_out.id}"
}

resource "aws_security_group_rule" "db_to_db_out" {
  security_group_id = "${aws_security_group.nomis_db_out.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "1521"
  to_port           = "1521"
  self              = true
  description       = "Inter db comms"
}

resource "aws_security_group_rule" "db_to_db_ssh_out" {
  security_group_id = "${aws_security_group.nomis_db_out.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  self              = true
  description       = "Inter db ssh comms"
}

resource "aws_security_group_rule" "db_to_eng_rman_catalog_out" {
  security_group_id        = "${aws_security_group.nomis_db_in.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${data.terraform_remote_state.ora_db_op_security_groups.sg_map_ids.rman_catalog}"
  description              = "RMAN Catalog out"
}
