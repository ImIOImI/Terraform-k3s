#!/bin/bash
ssh_key=$1
data_con=$2
role=$3
server_ip=$4
ip=$(hostname -I)

if [ $role = "server" ]
then
  #set up a server
  k3sup install --ip $ip --ssh-key $ssh_key --user ubuntu --context k3s --merge --datastore \"$data_con\"
else
  #set up an agent
  k3sup join --user ubuntu --server-ip $server_ip --ip --datastore \"$data_con\"
fi