#Just some helpful output 
locals {
  helpful_output = <<EOT
    #=====BEGIN HELPFUL OUTPUT=====
    #To get the ip of the k3s server run:
    ip=$(aws ec2 describe-instances --filters Name=tag:Name,Values=k3s-server Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddress[]" --output text)

    #To merge the kubeconfig with your local kubeconfig, run
    k3sup install --ip $ip --ssh-key ~/.ssh/${local.ssh_key_name}.pem --skip-install --user ubuntu --context k3s --merge

    #To ssh into the k3s server run:
    ssh ubuntu@$ip -i ~/.ssh/${local.ssh_key_name}.pem

    #To debug any node or startup errors, ssh into the node and run:
    cat /var/log/cloud-init-output.log
    #=====END HELPFUL OUTPUT=====
EOT
}

output "helpful_output" {
  depends_on = [module.agents]
  value = local.helpful_output
}