#  coreos-aws-terraform

Back in November, this was an attempt at building a Terraform equivalent of the Deis CloudFormation template for AWS.

I have vague memories of playing with https://github.com/ianblenke/docker-terraform and something like this:

    docker run -ti --rm -v `pwd`:/data ianblenke/terraform-build /gopath/bin/terraform apply -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}"

We ran into a challenge dealing with some missing functionality in the VPC definition. These did not work at the time (and may not still):

    "AssociatePublicIpAddress": {"Ref": "AssociatePublicIP"},
    "BlockDeviceMappings" : [
      {
        "DeviceName" : { "Fn::FindInMap": [ "RootDevices", { "Ref": "EC2VirtualizationType" }, "Name" ] },
        "Ebs" : { "VolumeSize" : "100" }
      }
    ]

If you make any headway with this, I would love to hear about it.

