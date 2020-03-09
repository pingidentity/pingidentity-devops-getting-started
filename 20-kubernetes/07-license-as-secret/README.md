The YAML files are used as follows:

* `configmap.yaml`

  Sets the server profile variables.

* `kustomization.yaml`

  Declares the deployment YAML resources and generates the license secret.

* `pingfederate.yaml`

  The Kubernetes deployment file. Contains the declaration and use of container volume mounts.

See the topic *Passing a license as a Kubernetes secret* in [Using an existing product license](../../docs/existingLicense.md) for more information.

> You'll need to provide your own license to use this example.
