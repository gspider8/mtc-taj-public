data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] # ignore date
  }
}

resource "random_id" "mtc_node_id" {
  byte_length = 2
  count       = var.main_instance_count
}

resource "aws_key_pair" "mtc_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "mtc_main" {
  count                  = var.main_instance_count
  instance_type          = var.main_instance_type
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.mtc-sg.id]
  subnet_id              = aws_subnet.mtc_public_subnet[count.index].id
  # user_data              = templatefile("./main-userdata.tpl", { new_hostname = "mtc-main-${random_id.mtc_node_id[count.index].dec}" })
  # replaced with ansible playbooks
  root_block_device {
    volume_size = var.main_vol_size
  }

  tags = {
    Name    = "mtc-main-${random_id.mtc_node_id[count.index].dec}"
    project = var.proj
  }
}

# this allows for the test of node-test.yml playbook to run
resource "aws_security_group_rule" "instance_ips" {
  description       = "instance ips"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"                                                               # any 
  cidr_blocks       = [for i in aws_instance.mtc_main[*] : format("%s/32", i.public_ip)] # list of all new ips
  security_group_id = aws_security_group.mtc-sg.id
  depends_on        = [aws_instance.mtc_main]
}

output "grafana_access" {
  value = { for i in aws_instance.mtc_main[*] : i.tags.Name => "${i.public_ip}:3000" }
}

output "instance_ips" {
  value = [for i in aws_instance.mtc_main[*] : i.public_ip]
}

output "instance_ids" {
  value = [for i in aws_instance.mtc_main[*] : i.id]
}