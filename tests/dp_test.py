# pylint: disable=missing-docstring, line-too-long, protected-access, E1101, C0202, E0602, W0109
import unittest
from runner import Runner


class TestE2E(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.snippet = """

            provider "aws" {
              region = "eu-west-2"
              skip_credentials_validation = true
              skip_get_ec2_platforms = true
            }

            module "data_pipeline" {
              source = "./mymodule"

              providers = {
                aws = "aws"
              }

              appsvpc_id                       = "1234"
              appsvpc_cidr_block               = "1.2.3.0/24"
              opssubnet_cidr_block             = "1.2.3.0/24"
              data_pipe_apps_cidr_block        = "10.1.8.0/24"
              data_pipe_rds_cidr_block         = "10.1.9.0/24"
              peering_cidr_block               = "1.1.1.0/24"
              az                               = "eu-west-2a"
              az2                              = "eu-west-2b"
              naming_suffix                    = "apps-preprod-dq"
              key_name                         = "test"
              archive_bucket                   = "arn:aws:s3:::thisisabucket"
              bucket_key                       = "arn:aws:kms:eu-west-2:111111111111:key/abcdabcdabcdabcd"
              dq_database_cidr_block_secondary = ["10.1.1.0/24"]
            }
        """
        self.result = Runner(self.snippet).result

    def test_root_destroy(self):
        self.assertEqual(self.result["destroy"], False)

    def test_data_pipe_apps(self):
        self.assertEqual(self.result['data_pipeline']["aws_subnet.data_pipe_apps"]["cidr_block"], "10.1.8.0/24")

    def test_data_pipe_rds(self):
        self.assertEqual(self.result['data_pipeline']["aws_subnet.data_pipe_rds_az2"]["cidr_block"], "10.1.9.0/24")

    def test_name_suffix_data_pipe_apps(self):
        self.assertEqual(self.result['data_pipeline']["aws_subnet.data_pipe_apps"]["tags.Name"], "subnet-data-pipeline-apps-preprod-dq")

    def test_name_suffix_dp_db(self):
        self.assertEqual(self.result['data_pipeline']["aws_security_group.dp_db"]["tags.Name"], "sg-db-data-pipeline-apps-preprod-dq")

    def test_name_suffix_dp_web(self):
        self.assertEqual(self.result['data_pipeline']["aws_security_group.dp_web"]["tags.Name"], "sg-web-data-pipeline-apps-preprod-dq")

    def test_name_suffix_dp_subnet_group(self):
        self.assertEqual(self.result['data_pipeline']["aws_db_subnet_group.rds"]["tags.Name"], "rds-subnet-group-data-pipeline-apps-preprod-dq")

    def test_name_suffix_dp_subnet2(self):
        self.assertEqual(self.result['data_pipeline']["aws_subnet.data_pipe_rds_az2"]["tags.Name"], "rds-subnet-az2-data-pipeline-apps-preprod-dq")

    def test_name_suffix_dp_rds(self):
        self.assertEqual(self.result['data_pipeline']["aws_db_instance.mssql_2012"]["tags.Name"], "rds-mssql2012-data-pipeline-apps-preprod-dq")



if __name__ == '__main__':
    unittest.main()
