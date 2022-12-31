# tf-core-api-infrastructure
Create API infrastructure for core APIs. The infrastructure defines the API signatures and callback, also the connections between gateway and computing infrastructure.

Before running, please make sure copying AWS credential to the project folder:

cd [project folder]
cd mkdir ./.aws
cp ~/.aws/credentials ./.aws

Then run:

terraform login

terraform init

terraform plan (or terraform apply)
