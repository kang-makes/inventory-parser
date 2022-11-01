locals {
    host_names_plain = [
        for host_filename in fileset("${local.inventory_path}/host_vars", "*.yaml"):
            regex("(.*)\\.yaml", host_filename)[0]
        if (length(regexall("\\.sops\\.yaml", host_filename)) == 0)
    ]
    host_names_crypted = [
        for host_filename in fileset("${local.inventory_path}/host_vars", "*.sops.yaml"):
            regexall("(.*)\\.sops\\.yaml", host_filename)[0][0]
    ]
    host_names = toset(concat(local.host_names_plain, local.host_names_crypted))

}

data sops_file host_decrypter {
    for_each    = toset(local.host_names_crypted)
    source_file = "${local.inventory_path}/host_vars/${each.value}.sops.yaml"
}

locals {
    hostvars_plain = {
        for host_name in local.host_names_plain:
            host_name => yamldecode(file("${local.inventory_path}/host_vars/${host_name}.yaml"))
    }
    hostvars_decrypted = {
        for host_name in local.host_names_crypted:
            host_name => yamldecode(data.sops_file.host_decrypter[host_name].raw)
    }
}

data utils_deep_merge_yaml hostvars_unmerged {
    input = [
        yamlencode(local.hostvars_plain),
        yamlencode(local.hostvars_decrypted)
    ]
}

locals {
    hostvars_unmerged = yamldecode(data.utils_deep_merge_yaml.hostvars_unmerged.output)
}

data utils_deep_merge_yaml hostvars {
    for_each = local.inventory_mapping_host_to_group

    input = flatten([
        yamlencode({"groups": each.value}),
        yamlencode(lookup(local.groupvars, "all", {})),
        [ for group in each.value: yamlencode(lookup(local.groupvars, group, {})) ],
        yamlencode(lookup(local.hostvars_unmerged, each.key, {}))
    ])
}

locals {
    hostvars = { 
        for key in keys(data.utils_deep_merge_yaml.hostvars): 
            key => yamldecode(data.utils_deep_merge_yaml.hostvars[key].output)
    }
}
