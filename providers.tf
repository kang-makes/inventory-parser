terraform {
  required_providers {
    sops = {
      source = "carlpett/sops"
      version = "0.7.1"
    }
  }
}

provider sops {}