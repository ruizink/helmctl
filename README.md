# helmctl

A tool that leverages Helm app lifecycle management to deploy RAW k8s manifests.

## Before we start

### Docker image required volumes

You need to mount the following volumes

* A valid `kubeconfig` under `/root/kubeconfig`

* The k8s `yaml` file with the manifest to apply under `/workspace`

Assuming that the manifest that we want to apply sits in the current working directory, the docker command would look something like this:

```bash
docker run -v $HOME/.kube/config:/root/kubeconfig -v $PWD:/workspace ruizink/helmctl:latest
```

## Usage

### Running the tool

To make things less verbose, we will start by creating an alias:

```bash
alias helmctl='docker run --rm -v $HOME/.kube/config:/root/kubeconfig -v $PWD:/workspace ruizink/helmctl:latest'
```

After that we can use the tool just like a native binary by simply running `helmctl`.

You can see below the help message and the list of accepted arguments:

```bash
helmctl --help
```

```text
Usage: helmctl <action> -n|--namespace <arg> -f|--filename <arg> -N|--app-name <arg> [-V|--app-version <arg>] [-t|--timeout <arg>] [-d|--debug <arg>] [-h|--help]
    <action>                   action to perform (options: 'apply')
    -n, --namespace string     namespace scope for this action
    -f, --filename string      path of the base k8s filename file for this action
    -N, --app-name string      the name of the deployment
    -V, --app-version string   (optional) the version description of the deployment
    -t, --timeout int          (optional) timeout in seconds (default: 300)
    --dry-run                  (optional) do not apply changes, show only the diff
    --debug                    (optional) enable debug messages
    -h, --help                 prints help
```

### Example deployment

Let's deploy a `manifest.yaml` to our cluster. This will deploy the resources defined in the manifest file under the `myapp-namespace` namespace and it will name this release `myapp`.

```bash
helmctl apply -f manifest.yaml -n myapp-namespace --app-name myapp
```

The tool will print a diff between the currently deployed state and the `manifest.yaml`.

Following that, the tool will create a Helm release.

You can check the Helm release status with the following command (check [here](https://helm.sh/docs/intro/install/) on how to install Helm):

```bash
helm history -n myapp-namespace myapp
```

```text
REVISION    UPDATED                     STATUS      CHART           APP VERSION DESCRIPTION
1           Wed Mar 25 21:46:08 2020    deployed    helmctl-0.1.0   0.0.0       Install complete
```

Since this tool produces essentially a Helm release, you can manage the life-cycle of the release using Helm.
