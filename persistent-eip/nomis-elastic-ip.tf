
resource "aws_eip" "nomis_nomis_az1_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-nomis-nomis-az1-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "nomis_nomis_az2_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-nomis-nomis-az2-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "nomis_nomis_az3_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-nomis-nomis-az3-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

