# inventory-parser

This was a attempt to read Ansible inventories using terraform. Red Hat did the other way around:

Use terraform to create an inventory: https://registry.terraform.io/providers/ansible/ansible/latest/docs/resources/host

Then use a inventory plugin to read the inventory created: https://github.com/ansible-collections/cloud.terraform/blob/main/docs/cloud.terraform.terraform_provider_inventory.rst

Was fun tho.
