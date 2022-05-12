---
title: Using a Utility Sidecar
---
# Using a Utility Sidecar
## Why Use a Sidecar
When running containerized software, each individual container should represent one process. This allows containers to be minimal and be allocated resources accurately.

There are common situtations where running commands and tools on the pod running some Ping Identity software is useful. For example, collecting a support archive, exporting data, or running a backup. But running these commands within the container running the actual server process can be risky, because these processes introduce unexpected contention for CPU and memory resources. The container within the pod is sized for the server process, not for auxilary processes that may be run at the same time.

To avoid running into these issues, it is recommended to use a utility sidecar for tools that may occasionally need to run alongside the server process. This sidecar runs as a separate container on the pod, but can be configured to share both a persistent volume and a process namespace with the main container. This will allow any needed processes to run without fighting for the same resources as the main server process.

The major downside of running a utility sidecar is that it must always be running, as new containers can't be attached to existing pods. The sidecar can be configured with minimal memory requests, but will still remaing running when it is not actively being used. Note that you cannot remove a sidecar from a running StatefulSet without rolling all the pods.

## How to Deploy a Sidecar
If you are using the [Ping Identity Helm charts](https://helm.pingidentity.com/), you can update your custom values.yaml file to enable a sidecar for any product. For example:
```
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

The above values will add a sidecar container using the same image as the main server container, configured with minimal resources and waiting in an endless loop. The generated yaml will look like this, which can be used outside of Helm:
```
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