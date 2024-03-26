#!/bin/bash

# Description:
#   This function is used to create an EC2 instance in AWS.
#
# Parameters:
#   - $1: The name of the EC2 instance (e.g. my-vm)
#   - $2: The size of the EC2 instance (e.g. t2.micro)
#   - $3: The OS the EC2 instance will use (e.g. ami-0d5d9d301c853a04a)
#   - $4: The region where the EC2 instance will be created (e.g. us-east-1)
#   - $5: [optional] The id of the security group to add the EC2 instance to (e.g. security-group-0d5d9d301c853a04a)
#   - $6: [optional] The id of the NIC the EC2 instance uses (e.g. eni-0d5d9d301c853a04a)
#   - $7: [optional] The id of the subnet the EC2 instance uses (e.g. subnet-0d5d9d301c853a04a)
#   - $8: [optional] The tags to use (e.g. "ResourceType=instance,Tags=[{Key=owner,Value=azure_devops},{Key=creation_time,Value=2024-03-11T19:12:01Z}]", default value is "ResourceType=instance,Tags=[{Key=owner,Value=azure_devops}]")
#
# Notes:
#   - this commands waits for the EC2 instance's state to be running before returning the instance id
#   - the instance id is returned if no errors occurred
#
# Usage: create_ec2 <name> <size> <os> <region> <subnet> [tag_specifications]
create_ec2() {
    local instance_name=$1
    local instance_size=$2
    local instance_os=$3
    local region=$4
    local nic="${5:-""}"
    local subnet="${6:-""}"
    local tag_specifications="${7:-"ResourceType=instance,Tags=[{Key=owner,Value=azure_devops}]"}"

    if [[ -n "$nic" ]]; then
        instance_id=$(aws ec2 run-instances --region "$region" --image-id "$instance_os" --instance-type "$instance_size" --network-interfaces "[{\"NetworkInterfaceId\": \"$nic\", \"DeviceIndex\": 0}]" --tag-specifications "$tag_specifications" --output text --query 'Instances[0].InstanceId')
    else
        instance_id=$(aws ec2 run-instances --region "$region" --image-id "$instance_os" --instance-type "$instance_size" --subnet-id "$subnet" --tag-specifications "$tag_specifications" --output text --query 'Instances[0].InstanceId')
    fi

    if [[ -n "$instance_id" ]]; then
        if aws ec2 wait instance-running --region "$region" --instance-ids "$instance_id"; then
            echo "$instance_id"
        fi
    fi
}

# Description:
#   This function is used to delete an EC2 instance in AWS.
#
# Parameters:
#   - $1: The id of the EC2 instance (e.g. i-0d5d9d301c853a04a)
#   - $2: The region where the EC2 instance was created (e.g. us-east-1)
#
# Notes:
#   - this commands waits for the EC2 instance's state to be terminated before returning the instance id
#   - the instance id is returned if no errors occurred
#
# Usage: delete_ec2 <instance_id> <region>
delete_ec2() {
    local instance_id=$1
    local region=$2

    if aws ec2 terminate-instances --region "$region" --instance-ids "$instance_id"; then
        if aws ec2 wait instance-terminated --region "$region" --instance-ids "$instance_id"; then
            echo "$instance_id"
        fi
    fi
}

# Description:
#   This function is used to create a NIC in AWS.
#
# Parameters:
#   - $1: The name of the NIC (e.g. nic_my-vm)
#   - $2: The id of the subnet the network interface uses (e.g. subnet-0d5d9d301c853a04a)
#   - $3: The id of the security group to add the network interface to (e.g. security-group-0d5d9d301c853a04a)
#   - $4: [optional] The tags to use (e.g. "ResourceType=network-interface,Tags=[{Key=owner,Value=azure_devops},{Key=creation_time,Value=2024-03-11T19:12:01Z}]", default value is "ResourceType=instance,Tags=[{Key=owner,Value=azure_devops}]")
#
# Notes:
#   - the NIC id is returned if no errors occurred
#
# Usage: create_nic <nic_name> <subnet> <security_group> [tag_specifications]
create_nic() {
    local nic_name=$1
    local subnet=$2
    local security_group=$3
    local tag_specifications="${4:-"ResourceType=network-interface,Tags=[{Key=owner,Value=azure_devops}]"}"

    nic_id=$(aws ec2 create-network-interface --description "$nic_name" --subnet-id "$subnet" --groups "$security_group" --tag-specifications "$tag_specifications" --output text --query 'NetworkInterface.NetworkInterfaceId')

    if [[ -n "$nic_id" ]]; then
        echo "$nic_id"
    fi
}

# Description:
#   This function is used to delete a NIC in AWS.
#
# Parameters:
#   - $1: The id of the NIC (e.g. eni-0d5d9d301c853a04a)
#
# Notes:
#   - the NIC id is returned if no errors occurred
#
# Usage: delete_nic <nic_id>
delete_nic() {
    local nic_id=$1

    if aws ec2 delete-network-interface --network-interface-id "$nic_id"; then
        echo "$nic_id"
    fi
}

# Description:
#   This function is used to retrieve a security group by filters
#
# Parameters:
#   - $1: The region where the security group is located (e.g. us-east-1)
#   - $2: The filters to use (e.g. "Name=tag:name,Values=create-delete-vm-sg")
#
# Usage: get_security_group_by_filters <region> <filters>
get_security_group_by_filters() {
    local region=$1
    local filters=$2

    aws ec2 describe-security-groups --region "$region" --filters $filters --output text --query 'SecurityGroups[0].GroupId'
}

# Description:
#   This function is used to retrieve a subnet by filters
#
# Parameters:
#   - $1: The region where the subnet is located (e.g. us-east-1)
#   - $2: The filters to use (e.g. "Name=tag:name,Values=create-delete-vm-subnet")
#
# Usage: get_subnet_by_filters <region> <filters>
get_subnet_by_filters() {
    local region=$1
    local filters=$2

    aws ec2 describe-subnets --region "$region" --filters $filters --output text --query 'Subnets[0].SubnetId'
}

# Description:
#   This function is used to retrieve a network interface by filters
#
# Parameters:
#   - $1: The region where the network interface is located (e.g. us-east-1)
#   - $2: The filters to use (e.g. "Name=tag:name,Values=create-delete-vm-network-interface")
#
# Usage: get_nic_by_filters <region> <filters>
get_nic_by_filters() {
    local region=$1
    local filters=$2

    aws ec2 describe-network-interfaces --region "$region" --filters $filters --output text --query 'NetworkInterfaces[0].NetworkInterfaceId'
}