#!/bin/bash
asg_name=$1
ssh_key=$2
data_con=$3

echo "$asg_name"
echo "ASG Name: $asg_name"
echo "SSH Key: $ssh_key"
echo "DATA con: $data_con"

ls -al ./rendered

for i in $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name "$asg_name" | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g')
do
  ip=$(aws ec2 describe-instances --instance-ids $i | grep -i PrivateIpAddress | awk '{ print $2 }' | head -1 | cut -d"," -f1)
  ip="${ip%\"}"
  ip="${ip#\"}"
  echo "$asg_name: $ip"
#  command="k3sup install --ip $ip --skip-install --ssh-key $ssh_key --user ubuntu --context k3s --merge --datastore \"$data_con\""
  command="k3sup install --ip http://k3s-server.dev.appiantesting.com --ssh-key $ssh_key --user ubuntu --context k3s --merge --datastore \"$data_con\""
#  command="k3sup install --ip $ip --skip-install --ssh-key $ssh_key --user ubuntu --context k3s --merge"
  echo $command
  $command
done;

echo "================================="
echo "login to the server with the following:"
echo "ssh ubuntu@$ip -i ~/.ssh/$ssh_key"
