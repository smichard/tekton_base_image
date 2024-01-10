# Tekton Task and Pipeline to send a notification to a Matrix Room

build custom container:
```bash
podman build --arch=amd64 -t quay.io/michard/developer_image:tekton-curl -f Containerfile
podman push quay.io/michard/developer_image:tekton-curl
```

create secret:
```bash
oc create -f matrix-secret.yml
```

create task and pipeline:
```bash
oc create -f task_matrix_notification.yml
oc create -f pipeline_matrix_notification.yml
```

trigger pipeline run:
```bash
oc create -f pipeline_run_matrix_notification.yml
or
tkn pipeline start pipeline-matrix --param=message="my custom message here" --showlog
```