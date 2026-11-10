# ************************* Operational Dockerfile *************************
# Starts from base image and adds automation scripts to it
# Dockerfile for base image is located in base-image directory
FROM public.ecr.aws/w1q7j9l2/imi-ubuntu-base-image:latest

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
RUN sed -i "s|CondaFile:.*|CondaFile: /home/ubuntu/.bashrc|g" ~/integrated_methane_inversion/config.yml
RUN sed -i "s|CondaEnv:.*|CondaEnv: imi_env|g" ~/integrated_methane_inversion/config.yml

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
