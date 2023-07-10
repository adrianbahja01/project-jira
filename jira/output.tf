output "elb-dns" {
    value = data.aws_elb.elb.dns_name
}

output "test" {
    value = data.aws_resourcegroupstaggingapi_resources.elb-api.resource_tag_mapping_list[0]
}
