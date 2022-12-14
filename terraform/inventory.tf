locals {
    inventory_hosts_raw = yamldecode(file("${var.inventory}/hosts.yaml"))

    inventory_mapping_host_to_group = transpose({
        for group in keys(local.inventory_hosts_raw.all.children):
            group => keys(local.inventory_hosts_raw.all.children[group].hosts)
    })

}
