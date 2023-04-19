# ali-terraform
create ali ecs for proxy

## usage
```
$ terraform init

replace ssh public_key, access_key and secret_key

$ terraform apply

$ terraform destroy
```

### base64 command
```
apt update && apt install shadowsocks-libev -y && sed -i 's/"::1", "127.0.0.1"/"0.0.0.0"/g; s/"password":.*/"password":"TopSecret",/g' /etc/shadowsocks-libev/config.json && systemctl restart shadowsocks-libev
```
