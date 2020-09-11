provider "aws" {
  region = "eu-central-1"
}

module "my_iam_user" {
  source = "../modules/iam"
#  key_name = "lsharma"
#  name = "lsharma"

}
