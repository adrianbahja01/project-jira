data "aws_availability_zones" "available_azs" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = "${var.project_name}-main"
  create_vpc      = true
  cidr            = var.vpc_cidr
  azs             = data.aws_availability_zones.available_azs.names
  public_subnets  = var.public_subnet_cidr
  private_subnets = var.private_subnet_cidr

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  tags = {
    Name = "${var.project_name}-main"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.project_name}-main" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.project_name}-main" = "shared"
    "kubernetes.io/role/elb"                      = 1
}
}
