# Introduction

This document shall summarize thoughts and instructions on how data cubes can be generated in the context of the DeepCube project. 
This is supposed to be a living document and shall be updated whenever new achievements have been made. 

## Status quo of the Earth System Data Cube

One of the project partners (MPG) was active in the consortium and co-created the so-called Earth System Data Cube. The idea behind this dataset was to bring together as many global Earth observation products as possible and make them ready for seamless multivariate analysis. 
Because of the research interest of the involved science partners, the focus of this data cube was to particularly enable efficient multivariate time series analysis on global datasets. In order to achieve this, we decided to regrid all involved 
variables to a common spatiotemporal grid. Although this involved some data duplication and increase of storage, we concluded
that instant access to a variety of datasets preferable. 
The initial plan for the DeepCube project (according to the proposal) was to use the cube generation software used to generate the ESDC to create custom data cubes for the single use cases 

## Communicated Requirements by the users

As a result of the DeepCube kickoff meeting as well as individual discussions it became apparent that the current data cube model, that does a regridding to a common spatiotemporal resolution is not feasible for most of the use cases. 
The main problem is that many data either come on high spatial and low temporal resolution (e.g. Sentinel, MODIS) or on high temporal and low spatial resolution (e.g. ERA5). In order to bring datasets of these different scale together with the ESDC approach, on would have to interpolate heavily, which would drastically increase the data volume. 
Therefore many of the use cases dealing with large data volumes were interested in so-called multi-resolution data cubes, 
where datasets are stored on their original resolution and re-gridded on the fly 

# Cube Generation - Howto

## Why rewrite the data at all?

As many use cases aim to generate multi-resolution data cubes, one might ask the question why an additional data cube generation step would be necessary at all. For example the OpenDataCube initiative has taken an approach where the original
data remains more or less untouched and a database of the existing files and layers is built which helps for efficient access to the data. The most important consideration here is chunking. Usually the original data is stored in a format where spatially close points are close on disk, i.e. the data is stored in the physical unit of images. Depending on the use case, however, it might be necessary to do operations where one needs to access a full multi-year time series for a certain spatial coordinate, or access many of the time series sequentially. 
In this case, re-chunking the data so that chunks span over a longer temporal extent is essential. The second reason to re-write the data instead of only creating views into the original data is chunk alignment. In order to have most efficient access to a multivariate dataset, it is important that chunk boundaries of the individual variables align. Ideally, for training applications, a chunk would have exactly the size and shape of a single training batch, so that no excess data has to be read or transferred. 
If all one wants to do is e.g. image classification on a univariate dataset, then rewriting the data is not necessary and the original data can be accessed directly (and maybe indexed before, if loading the dataset takes too long, maybe through approaches like https://xpublish.readthedocs.io/en/latest/ or by building an OpenDataCube)
However, if one wants to operate on time series, e.g. training an LSTM model that operates on full time series at a by-pixel level, one would have to rewrite the data once to a new data cube and a chunk size that has maximum extent in time. 
If one wants to train a model on short sequences of images (i.e. video prediction, ), one would use chunks that reflect exactly the size of an image sequence. 

## General considerations

Currently, in order for all of the python-based approaches to work, one needs to bring the original data to a common spatial reference system. This is required so that the regridding approaches taken in xcube etc are possible. Here we suggest to use tools like gdalwarp which allow you to reproject arbitrary images to a regular lon-lat grid. 
- unify metadata by loading into a common framework (xarray)
- save the data and hope for Dask to solve chunking problems

## Generating single-resolution data cubes


## Cube generation in Julia using EarthDataLab.jl

- If you want to use Julia for the data cube generation you can follow the [tutorial notebook](loads1tifs.jl)

To start this tutorial you have to start Julia 1.6 in this folder and then you have to start Pluto with the current folder as environment by 
```julia
Pluto.run(;project="@.")
```

Then you can select the notebook inside of Pluto.

## Minicube generation in Python using xarray/rioxarray functionality only

This is a minimal example on how to build data cubes using xarray only. It is assumed that all inputs are already transformed to a EPSG:4326 longitude-latitude grid using tools like gdalwarp:

````
gdalwarp -t_srs EPSG:4326 input.tif output.nc
````

optionally one can crop and regrid the files already during this step by setting target extent (`-te `) and target resolution (using `tr` or `ts` options).

See [datacube_gen_python](./datacube_gen_python.ipynb#minicube)

## Using xcube

See [datacube_gen_python](./datacube_gen_python.ipynb#xcube)

# Rechunking
## Using python rechunker and Dask
See [datacube_gen_python](./datacube_gen_python.ipynb#rechunker)

## Using julia
See example in [datacube_rechunk](./datacube_rechunk_example.jl)
## Using nco
See [datacube_gen_python](./datacube_gen_python.ipynb#ncrechunk)

# Publishing data cube
See [datacube_publish](./datacube_publish.md)