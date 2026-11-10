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
RUN sed -i "s|^PythonEnv:.*|PythonEnv: \"/home/ubuntu/integrated_methane_inversion/envs/container/python.env\"|" ~/integrated_methane_inversion/config.yml

# Python packages 2.3.1 imports that the base image's imi_env lacks:
#   sparselt  (src/utilities/make_state_vector_file.py)
#   pygeohash (src/inversion_scripts/operators/satellite_operator.py)
#   tabulate  (plumes.py)
# Pinned; --no-deps keeps the tested environment unchanged.
RUN /home/ubuntu/bin/micromamba run -n imi_env pip install --no-cache-dir --no-deps pygeohash==3.5.1 tabulate==0.10.0 "git+https://github.com/LiamBindle/sparselt.git@e8353c947317703d417d899d663cf0ddd11865ab"

CMD [ "/home/ubuntu/integrated_methane_inversion/resources/containers/ubuntu/entrypoint.sh" ]
