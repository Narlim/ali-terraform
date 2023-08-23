provider "alicloud" {
  access_key = "${access_key}"
  secret_key = "${secret_key}"
  region     = "cn-hongkong"
}

resource "alicloud_ecs_key_pair" "pair" {
  key_pair_name = "my_arch"
  public_key    = "${public_key}"
}

resource "alicloud_vpc" "vpc" {
  vpc_name   = "my_vpc"
  cidr_block = "192.168.0.0/16"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = "192.168.1.0/24"
  zone_id    = "cn-hongkong-b"
}

resource "alicloud_security_group" "default" {
  name   = "default"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "instance" {
  availability_zone = "cn-hongkong-b"
  security_groups   = alicloud_security_group.default.*.id
  instance_type              = "ecs.t5-lc2m1.nano"
  spot_duration              = 0
  system_disk_category       = "cloud_efficiency"
  system_disk_size           = 20
  image_id                   = "debian_11_6_uefi_x64_20G_alibase_20230217.vhd"
  instance_name              = "temp-proxy"
  vswitch_id                 = alicloud_vswitch.vsw.id
  internet_charge_type       = "PayByTraffic"
  internet_max_bandwidth_out = 100
}

resource "alicloud_ecs_key_pair_attachment" "attachment" {
  key_pair_name = alicloud_ecs_key_pair.pair.id
  instance_ids  = alicloud_instance.instance.*.id
}

resource "alicloud_ecs_command" "init" {
  name = "install"
  type = "RunShellScript"
  command_content = "YXB0IHVwZGF0ZSAmJiBhcHQgaW5zdGFsbCBzaGFkb3dzb2Nrcy1saWJldiAteSAmJiBzZWQgLWkgJ3MvIjo6MSIsICIxMjcuMC4wLjEiLyIwLjAuMC4wIi9nOyBzLyJwYXNzd29yZCI6LiovInBhc3N3b3JkIjoiRXZGUkVkR0F6K2taZGJ5a2haZGo1dz09IiwvZycgL2V0Yy9zaGFkb3dzb2Nrcy1saWJldi9jb25maWcuanNvbiAmJiBzeXN0ZW1jdGwgcmVzdGFydCBzaGFkb3dzb2Nrcy1saWJldg=="
}

resource "alicloud_ecs_invocation" "default" {
  command_id  = alicloud_ecs_command.init.id
  instance_id = alicloud_instance.instance.*.id
}
