terraform {
  cloud {
    organization = "DatacentR"
    workspaces {
      name = "az-function-workspace"
    }
  }
}