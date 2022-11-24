# Publish data cubes on OVH object store

Data cubes used by DeepCube Use Cases are published on the OVH store, part of the [DeepCube Platform](https://deepcube.gael-systems.com/).

## Create data cube as zarr file

First of all to deploy this efficiently on the object store you will need to convert the dataset to zarr format. This is usually done with Python `xarray` by loading the dataset and then calling `ds.to_zarr("path/to/output")`. See [datacube_gen_python](./datacube_gen_python.ipynb) for details.

Make sure to **consolidate metadata** before going to the next step. Thre should be a .zmetadata file in the zarr folder, e.g. `mycube.zarr/.zmetadata`.

## Cube deployment with Swift (OpenStack Object store project) {#cube_depl}

Next step would be to upload the zarr file to the swift OVH store. 

You first need to install the conda packages python-swiftclient and python-keystoneclient to upload the data.

```bash
conda install -c conda-forge python-swiftclient
conda install -c conda-forge python-keystoneclient
```

You then need to authenticate with the swift object store. You run [this script](./openstack_auth.sh) to set the swift credentials, the user password is available on request. 

```bash
$ source ./openstack_auth.sh
```
### Test swift connection 

To see the available containers, you can run 
```bash
$ swift list
```

You can list the content of a specific container using 

```bash
$swift list container_name
```
### Swift upload

You can upload your cube to the container using `swift upload`. Make sure to give the cube a different name than those already in the container!

See also the documentation here:
https://docs.openstack.org/python-swiftclient/latest/cli/index.html#swift-usage

```bash
# upload
$ swift upload <to_container_name> <file_name>
# delete
$ swift delete <from_container_name> <object>
```
### Make container public
Once the data is uploaded and you want to share it with the world, you can make it public by running the following line:
```bash
$ swift post container_name --read-acl ".r:*,.rlistings"
```

## Access object store with https

Afterwards users can access the data directly from **xarray** with the following lines of python code:

```python
import xarray as xr
import fsspec
m = fsspec.get_mapper('https://storage.de.cloud.ovh.net/v1/AUTH_84d6da8e37fe4bb5aea18902da8c1170/uc3/FireCube_time1_x1253_y983.zarr')
xr.open_zarr(m)
```


