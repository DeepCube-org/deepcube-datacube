using Pkg
pkg"add NetCDF Zarr YAXArrays"

using YAXArrays, Zarr, NetCDF

target_chunks = (time=200,lon=90,lat=90)

#Path to file, can be either folder containing Zarr or NetCDF file
ds = open_dataset("/Net/Groups/BGI/work_1/scratch/s3/esdl-esdc-v2.1.1/esdc-8d-0.083deg-1x2160x4320-2.1.1.zarr/")

dssub = ds[[:gross_primary_productivity,:net_ecosystem_exchange,:leaf_area_index]]

dschunked = setchunks(dssub,target_chunks)

savedataset(dschunked,path = "./rechunked_esdc.zarr", max_cache=1e9, backend = :zarr,overwrite = false)
#max_cache determines the amount of memory to be used for rechunking, the larger this is, the faster the rechunking will go
#backend can be either :zarr or :netcdf
#setting overwrite=true will delete any existing dataset



ds2 = open_dataset("/Net/Groups/BGI/work_1/scratch/s3/esdl-esdc-v2.1.1/esdc-8d-0.083deg-184x270x270-2.1.1.zarr/")

anothervar = setchunks(ds2[[:air_temperature_2m,:terrestrial_ecosystem_respiration]],target_chunks)

#We set append=true to write into the existing dataset
savedataset(anothervar,path = "./rechunked_esdc.zarr", max_cache=1e9, backend = :zarr,overwrite = false, append=true)