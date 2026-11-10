# ************************* Operational Dockerfile *************************
# Starts from base image and adds automation scripts to it
# Dockerfile for base image is located in base-image directory
# Pinned to the base image digest this branch was tested with (tag: latest on 2026-11-09)
FROM public.ecr.aws/w1q7j9l2/imi-ubuntu-base-image@sha256:12ffe82479a208b22ca7011e4f1c8a59417f7455320ffe7b5fadb1d63d126129

USER ubuntu

# make relevant directories for the imi
RUN mkdir /home/ubuntu/imi_output_dir && mkdir /home/ubuntu/ExtData

# add imi source code to base image
ADD ./ /home/ubuntu/integrated_methane_inversion

# change ownership of the imi source code to ubuntu user
RUN sudo chown ubuntu:ubuntu -R /home/ubuntu/integrated_methane_inversion/

# make imi run scripts executable
RUN chmod +x /home/ubuntu/integrated_methane_inversion/run_imi.sh
RUN chmod +x /home/ubuntu/integrated_methane_inversion/resources/containers/ubuntu/entrypoint.sh
RUN cd /home/ubuntu/integrated_methane_inversion/ && git fetch --tags

# update default config.yml file TODO remove
RUN sed -i "s/v2024-03/v2023-06/g" ~/integrated_methane_inversion/config.yml
# use the container's micromamba environment (2.3.1 reads PythonEnv; CondaFile/CondaEnv are gone)
RUN sed -i "s|^PythonEnv:.*|PythonEnv: \"envs/container/python.env\"|" ~/integrated_methane_inversion/config.yml

# Python packages 2.3.1 imports that the base image's imi_env lacks:
#   sparselt  (src/utilities/make_state_vector_file.py)
#   pygeohash (src/inversion_scripts/operators/satellite_operator.py)
#   tabulate  (plumes.py)
# Pinned; --no-deps keeps the tested environment unchanged.
RUN /home/ubuntu/bin/micromamba run -n imi_env pip install --no-cache-dir --no-deps pygeohash==3.5.1 tabulate==0.10.0 "git+https://github.com/LiamBindle/sparselt.git@e8353c947317703d417d899d663cf0ddd11865ab"

# aari-shared-server site support (used by envs/aari/config.aari.yml): a data root whose
# entries link to the server's S3 mounts, so IMI reads inputs in place instead of downloading.
# The links dangle unless /s3/... is mounted; IMI's own /home/ubuntu/ExtData is unchanged.
RUN mkdir -p /home/ubuntu/aari-ExtData && cd /home/ubuntu/aari-ExtData && \
    for d in CHEM_INPUTS GEOSCHEM_RESTARTS HEMCO Observations GEOS_NATIVE GEOS_2x2.5 GEOS_4x5 GEOS_0.5x0.625 GEOS_0.5x0.625_AS GEOS_0.5x0.625_EU GEOS_0.5x0.625_NA GEOS_0.25x0.3125 GEOS_0.25x0.3125_AF GEOS_0.25x0.3125_AS GEOS_0.25x0.3125_EU GEOS_0.25x0.3125_ME GEOS_0.25x0.3125_NA GEOS_0.25x0.3125_OC GEOS_0.25x0.3125_RU GEOS_0.25x0.3125_SA GEOS_0.125x0.15625_AF GEOS_0.125x0.15625_AS GEOS_0.125x0.15625_EU GEOS_0.125x0.15625_ME GEOS_0.125x0.15625_NA GEOS_0.125x0.15625_OC GEOS_0.125x0.15625_RU GEOS_0.125x0.15625_SA; do \
      ln -s /s3/gcgrid/$d $d; \
    done && \
    ln -s /s3/imi-boundary-conditions BoundaryConditions && \
    ln -s /s3/blended-tropomi-gosat-methane blended-tropomi-gosat-methane && \
    ln -s /s3/meeo-s5p meeo-s5p

CMD [ "/home/ubuntu/integrated_methane_inversion/resources/containers/ubuntu/entrypoint.sh" ]
