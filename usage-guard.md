# guard

* <https://github.com/appscode/guard/blob/master/docs/setup/install.md>
* <https://github.com/appscode/guard/blob/master/docs/guides/authenticator/google.md>

## generate server certificate pair

```bash
ips="$(kubectl get svc --all-namespaces | grep ClusterIP | awk '{print $4}' | head -1 | cut -d'.' -f1,2).10.96"
echo ${ips}

# initialize self signed ca
guard init ca

# generate server certificate pair
guard init server --ips=${ips}

# generate server certificate pair
guard init client bespinglobal.com -o google

guard init client opsnow -o github

guard init client opsnow -o ldap

ls -l $HOME/.guard/pki
```

## generate Kubernetes YAMLs for deploying guard server

```bash
# google
guard get installer \
    --auth-providers="google" \
    --google.admin-email=<email-of-a-g-suite-admin> \
    --google.sa-json-file=<path-json-key-file> \
    > guard-installer.yaml

# github
guard get installer \
    --auth-providers="github" \
    > guard-installer.yaml

# ldap
guard get installer \
    --auth-providers="ldap" \
    --ldap.server-address=<server_address> \
    --ldap.server-port=<server_port> \
    --ldap.bind-dn=<bind_dn> \
    --ldap.bind-password=<bind_password> \
    --ldap.user-search-dn=<user_search_dn> \
    --ldap.user-search-filter=<user_search_filter> \
    --ldap.user-attribute=<user_attribute> \
    --ldap.group-search-dn=<group_search_dn> \
    --ldap.group-search-filter=<group_search_filter> \
    --ldap.group-name-attribute=<group_name_attribute> \
    --ldap.group-member-attribute=<group_member_attribute> \
    --ldap.skip-tls-verification=<true/false> \
    --ldap.start-tls=<true/false>\
    --ldap.is-secure-ldap=<true/false>\
    --ldap.ca-cert-file=<path_to_the_ca_cert_file>
    --ldap.auth-choice=<Simple/Kerberos>
    > guard-installer.yaml

# IP 변경
cp guard-installer.yml /tmp/tmp.yml && cat /tmp/tmp.yml | sed -e "s/10.96.10.96/${ips}/g" > guard-installer.yml

# 주석 처리
cp guard-installer.yml /tmp/tmp.yml && cat /tmp/tmp.yml | sed -e "s|nodeSelector:|# nodeSelector:|g" > guard-installer.yml
cp guard-installer.yml /tmp/tmp.yml && cat /tmp/tmp.yml | sed -e "s|node-role.kubernetes.io/master:|# node-role.kubernetes.io/master:|g" > guard-installer.yml

# 적용
kubectl apply -f guard-installer.yml

kubectl get deployment,pod,svc -n kube-system
```

## webhook authentication

```bash

guard get webhook-config opsnow -o ldap --addr=${ips}:443

```
