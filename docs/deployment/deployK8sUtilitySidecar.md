---
title: Using a Utility Sidecar
---
# Using a Utility Sidecar
## Why Use a Sidecar
When running containerized software, each individual container should represent one process. This allows containers to be minimal and be allocated resources accurately.

There are common situations where running commands and tools on the pod running Ping Identity software is useful. For example, collecting a support archive, exporting data, or running a backup. However, because these processes introduce unexpected contention for CPU and memory resources, running these commands within the container running the actual server process can be risky. The container within the pod is sized for the server process, not for auxiliary processes that can be run at the same time.

To avoid these issues, use a utility sidecar for tools that might need to run alongside the server process. This sidecar runs as a separate container on the pod, but can be configured to share both a persistent volume and a process namespace with the main container. This allows any required processes to run without competing with the main server process for the same resources.

The major downside of running a utility sidecar is that it must always be running because new containers can't be attached to existing pods. The sidecar can be configured with minimal memory requests, but will continue to run when it is not actively in use. 

!!! note
    You cannot remove a sidecar from a running StatefulSet without rolling all the pods.

## How to Deploy a Sidecar
If you are using the [Ping Identity Helm charts](https://helm.pingidentity.com/), you can update your custom values.yaml file to enable a sidecar for any product. For example:

```yaml
pingdirectory:
  enabled: true
  workload:
    # Share process namespace for sidecar to get a view inside the main container
    shareProcessNamespace: true
  # Share /tmp so sidecar can see Java processes. Don't keep /tmp around between restarts though.
  volumes:
  - name: temp
    emptyDir: {}
  volumeMounts:
  - name: temp
    mountPath: /tmp
  # Backups, restores, and other CLI tools should be run from the sidecar to prevent interfering
  # with the main PingDirectory container process.
  utilitySidecar:
    enabled: true
```

These values will add a sidecar container using the same image as the main server container, configured with minimal resources and waiting in an endless loop. The generated yaml will look like the following, which can be used outside of Helm:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app.kubernetes.io/name: pingdirectory
  name: sidecar-pingdirectory
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: pingdirectory
  serviceName: sidecar-pingdirectory-cluster
  template:
    metadata:
      labels:
        app.kubernetes.io/name: pingdirectory
    spec:
      containers:
      - envFrom:
        - secretRef:
            name: devops-secret
            optional: true
        image: pingidentity/pingdirectory:latest
        livenessProbe:
          exec:
            command:
            - /opt/liveness.sh
          failureThreshold: 4
          initialDelaySeconds: 30
          periodSeconds: 30
          successThreshold: 1
          timeoutSeconds: 5
        name: pingdirectory
        ports:
        - containerPort: 1443
          name: https
        - containerPort: 1389
          name: ldap
        - containerPort: 1636
          name: ldaps
        readinessProbe:
          exec:
            command:
            - /opt/readiness.sh
          failureThreshold: 4
          initialDelaySeconds: 30
          periodSeconds: 30
          successThreshold: 1
          timeoutSeconds: 5
        resources:
          limits:
            cpu: 2
            memory: 8Gi
          requests:
            cpu: 50m
            memory: 2Gi
        startupProbe:
          exec:
            command:
            - /opt/liveness.sh
          failureThreshold: 180
          periodSeconds: 10
          timeoutSeconds: 5
        volumeMounts:
        - mountPath: /tmp
          name: temp
        - mountPath: /opt/out
          name: out-dir
      - args:
        - -f
        - /dev/null
        command:
        - tail
        image: pingidentity/pingdirectory:latest
        name: utility-sidecar
        resources:
          limits:
            cpu: "1"
            memory: 2Gi
          requests:
            cpu: "0"
            memory: 128Mi
        volumeMounts:
        - mountPath: /opt/out
          name: out-dir
        - mountPath: /tmp
          name: temp
      securityContext:
        fsGroup: 0
        runAsGroup: 0
        runAsUser: 9031
      shareProcessNamespace: true
      terminationGracePeriodSeconds: 300
      volumes:
      - emptyDir: {}
        name: temp
      - name: out-dir
        persistentVolumeClaim:
          claimName: out-dir
  volumeClaimTemplates:
  - metadata:
      name: out-dir
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 8Gi
      storageClassName: null
```