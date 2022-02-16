# sealed-secrets

## install

```bash
brew install kubeseal
```

## secret.yaml

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

## sealed-secret.yaml

```bash
cat secret.yaml | kubeseal \
    --controller-namespace addon-sealed-secrets \
    --controller-name sealed-secrets \
    --format yaml \
    > sealed-secret.yaml
```
