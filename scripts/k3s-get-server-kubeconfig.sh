#!/bin/bash
ip=$1
ssh_key=$2
data_con=$3

echo "Ip: $ip"
echo "SSH Key: $ssh_key"
echo "DATA con: $data_con"

ls -al ./rendered

command="k3sup install --ip $ip --ssh-key $ssh_key --skip-install --user ubuntu --context k3s --merge --datastore \"$data_con\""
echo $command
$command

echo "================================="
echo "login to the server with the following:"
echo "ssh ubuntu@$ip -i ~/.ssh/$ssh_key"