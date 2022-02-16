# sealed-secrets

## install

```bash
brew install kubeseal
```

## secrets.yaml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sample-secret
  namespace: sample
data:
  password: dGVzdAo= # <- base64 encoded test
  username: dGVzdDEyMzQK # <- base64 encoded test1234
```

##

```bash
cat secret.yaml | kubeseal \
    --controller-namespace addon-sealed-secrets \
    --controller-name sealed-secrets \
    --format yaml \
    > sealed-secret.yaml
```
