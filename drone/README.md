
# Kubernetes cluster
* version >= `1.10`

# create namespace `drone`

    kubectl create namespace drone

# setup ngrok service
*Only needed if no external LB is configured in the k8s cluster*
Ngrok will exposes the services URL to the outside trough a revers-proxy

* setup ngrok account
* create authtoken: https://dashboard.ngrok.com/auth
* create file `ngrok.yml`:
```yaml
authtoken: <authtoken-val>
```
* create a kubernetes secret: `kubectl create secret generic ngrok-token --from-file=$HOME/.ngrok2/ngrok.yml`
* Apply stateful set for ngrok: `kubectl apply --filename=drone/ngrok.yaml`

# setup drone
* Create service account and role binding: `kubectl apply -f drone/drone-sa-role.yaml `
* create github oauth: https://github.com/settings/applications
  * URL: https://<ngrok-server>
  * Callback URL: https://<ngrok-server>/login
* Fill out values of in file `drone-github.env`:
  * `DRONE_ADMIN`
  * `DRONE_GITHUB_CLIENT_ID`
  * `DRONE_GITHUB_CLIENT_SECRET` 
  * `DRONE_SERVER_HOST`    
* Create `drone-secrets`: `kubectl create secret generic drone-secrets --from-env-file=drone/drone-github.env`
* Create Deployment: `kubectl apply -f drone/drone-deployment.yaml`
