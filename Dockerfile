# Use the specified base image
FROM runpod/pytorch:2.2.0-py3.10-cuda12.1.1-devel-ubuntu22.04

# Set the working directory
WORKDIR /workspace

# Install git
RUN apt-get update && apt-get install -y git

# Clone the repository
RUN git clone https://github.com/isaacwasserman/Isaacs_ComfyUI_Distro

# Change to the repository directory and run the setup script
RUN cd Isaacs_ComfyUI_Distro && sh setup.sh

# Set the working directory back to /workspace
WORKDIR /workspace
