terraform {
  backend "remote" {
    organization = "ealmeidaneto-io"

    workspaces {
      name = "ealmeidaneto"
    }
  }
}
