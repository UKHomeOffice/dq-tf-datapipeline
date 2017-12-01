# pylint: disable=missing-docstring, line-too-long, protected-access
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

              appsvpc_id                  = "1234"
              appsvpc_cidr_block          = "1.2.3.0/24"
              opsvpc_cidr_block           = "1.2.3.0/24"
              data_pipe_apps_cidr_block   = "10.1.8.0/24"
              az                          = "eu-west-2a"
              name_prefix                 = "dq-"
            }
        """
        self.result = Runner(self.snippet).result

    def test_root_destroy(self):
        self.assertEqual(self.result["destroy"], False)

    def test_data_pipe_apps(self):
        self.assertEqual(self.result['data_pipeline']["aws_subnet.data_pipe_apps"]["cidr_block"], "10.1.8.0/24")

    def test_name_prefix_data_pipe_apps_subnet(self):
        self.assertEqual(self.result['data_pipeline']["aws_subnet.data_pipe_apps"]["tags.Name"], "dq-apps-data-pipeline-subnet")

    def test_name_prefix_dp_postgres(self):
        self.assertEqual(self.result['data_pipeline']["aws_instance.dp_postgres"]["tags.Name"], "dq-apps-data-pipeline-postgres")

    def test_name_prefix_dp_web(self):
        self.assertEqual(self.result['data_pipeline']["aws_instance.dp_web"]["tags.Name"], "dq-apps-data-pipeline-web")

    def test_name_prefix_bastions_db(self):
        self.assertEqual(self.result['data_pipeline']["aws_security_group.bastions_db"]["tags.Name"], "dq-apps-data-pipeline-db-sg")

    def test_name_prefix_bastions_web(self):
        self.assertEqual(self.result['data_pipeline']["aws_security_group.bastions_web"]["tags.Name"], "dq-apps-data-pipeline-web-sg")

    # def test_bastions_db(self):
    #     self.assertEqual(self.result['data_pipeline']["aws_security_group.bastions_db"]["ingress.from_port"], "1433")
    #
    # def test__bastions_db(self):
    #     self.assertEqual(self.result['data_pipeline']["aws_security_group.bastions_db"]["ingress.to_port"], "1433")
    #
    # def test_bastions_db(self):
    #     self.assertEqual(self.result['data_pipeline']["aws_security_group.bastions_db"]["ingress.protocol"], "tcp")
    #
    # def test_bastions_db(self):
    #     self.assertEqual(self.result['data_pipeline']["aws_security_group.bastions_db"]["ingress.from_port"], "3389")
    #
    # # def test_bastions_db(self):
    # #     self.assertEqual(self.result['data_pipeline']["aws_security_group.bastions_db"]["ingress.to_port"], "3389")
    #
    # def test_bastions_db(self):
    #     self.assertEqual(self.result['data_pipeline']["aws_security_group.bastions_db"]["ingress.protocol"], "tcp")
    #
    # def test_bastions_db(self):
    #     self.assertEqual(self.result['data_pipeline']["aws_security_group.bastions_db"]["egress.protocol"], "-1")
    #
    # def test_bastions_db(self):
    #     self.assertEqual(self.result['data_pipeline']["aws_security_group.bastions_db"]["egress.from_port"], "0")
    #
    # def test_bastions_db(self):
    #     self.assertEqual(self.result['data_pipeline']["aws_security_group.bastions_db"]["egress.to_port"], "-1")
    #
    # # def test_bastions_db(self):
    # #     self.assertEqual(self.result['data_pipeline']["aws_security_group.bastions_db"]["egress.cidr_blocks"], "0.0.0.0/0")


if __name__ == '__main__':
    unittest.main()
