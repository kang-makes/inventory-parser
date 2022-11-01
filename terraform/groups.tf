locals {
    group_names_plain = [
        for group_filename in fileset("${local.inventory_path}/group_vars", "*.yaml"):
            regex("(.*)\\.yaml", group_filename)[0]
        if (length(regexall("\\.sops\\.yaml", group_filename)) == 0)
    ]
    group_names_crypted = [
        for group_filename in fileset("${local.inventory_path}/group_vars", "*.sops.yaml"):
            regexall("(.*)\\.sops\\.yaml", group_filename)[0][0]
    ]
    group_names = toset(concat(local.group_names_plain, local.group_names_crypted))

}

data sops_file group_decrypter {
    for_each    = toset(local.group_names_crypted)
    source_file = "${local.inventory_path}/group_vars/${each.value}.sops.yaml"
}

locals {
    groupvars_plain = {
        for group_name in local.group_names_plain:
            group_name => yamldecode(file("${local.inventory_path}/group_vars/${group_name}.yaml"))
    }
    groupvars_decrypted = {
        for group_name in local.group_names_crypted:
            group_name => yamldecode(data.sops_file.group_decrypter[group_name].raw)
    }
}

data utils_deep_merge_yaml groupvars {
  input = [
    yamlencode(local.groupvars_plain),
    yamlencode(local.groupvars_decrypted)
  ]
}

locals {
    groupvars = yamldecode(data.utils_deep_merge_yaml.groupvars.output)
}