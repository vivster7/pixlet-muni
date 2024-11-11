# pixlet-muni

SFMTA Muni updates for myself

![pixlet-muni](https://user-images.githubusercontent.com/1903527/214772738-66b5e1c8-0db5-40de-bfda-28fc90f9ee5a.gif)

Inspiration from:

- https://github.com/tidbyt/community/tree/main/apps/sfnextmunia

To fix the error:

```
{"code":9,"message":"device must have at least one app installed","details":[]}
```

You must do at least one manual run of `pixlet push` with the flag `--installation-id pixletmuni`, so the Tidbyt will have an app installed.

Command to install the k3s-deploy folder on a k3s cluster (will need to write a values.yaml file with the secret):

```
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install pixlet-muni ./k3s-deploy -f k3s-deploy/values-secret.yaml
```
