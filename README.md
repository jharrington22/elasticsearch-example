## elasticsearch-example

An example elasticsearch node

- Cloudformation
- Chef-zero
- Elasticsearch
- Nginx

### Design & Implementation decisions

#### Chef-zero

  - Ability to mock a real chef server if requried (over kill for this example)

#### Cloudformation

  - Sets up a VPC, ACL's and security groups. I've also included an instance role which I had planned to use with the S3 bucket however that wouldn't work if run from another account
  - user-data is used to bootstrap the instance with chef-client, ruby and Github repo

#### Elasticsearch

  - Jetty was a consideration but due to time restrictions I wasn't able to research it and decided to use Nginx proxying and basic HTTP auth instead
  - Elasticsearch looks to have a few plugins that can improve security, I would expect that some of those effect performance. Nginx should be pretty transparent in terms of performance impact

#### Nginx

  - Using proxy pass to keep Elasticsearch's main TCP port secure
  - Basic HTTP auth for username/password authentication
  - I could have restricted queries to read only here by allowing only GET requests
  - Nginx allow's us to apply rate limiting, IP filtering and other techniques to secure elasticsearch
  - Its fast and lightweight

### Notes for setup

- Make sure you update the x.x.x.x/x below with your source IP for access to the instance

- Cloudformation template is globally available for this example so it can be run easily

#### Setup

1. Create a key-pair

`aws --region us-east-1 ec2 create-key-pair --key-name "elasticsearch-example" | jq -r ".KeyMaterial" > ~/.ssh/elasticsearch-example.pem`

2. Deploy AWS VPC, Network ACL's, Security Group and Instance

`aws --region us-east-1 cloudformation create-stack --stack-name ElasticsearchExample --template-url https://s3.amazonaws.com/elasticsearch-example/elasticsearch.template.json --parameters ParameterKey=SSHLocation,ParameterValue="x.x.x.x/x" --capabilities CAPABILITY_IAM`

#### Resources

- https://github.com/agileorbit-cookbooks/java
- https://github.com/elastic/cookbook-elasticsearch
- https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html

#### Feedback

With more time I could have expanded this to setup a cluster. Looks like its fairly straight forward with the Chef cookbook and the AWS Cloud plugin.

