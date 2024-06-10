# Use the official Amazon Linux 2 as the base image
FROM amazonlinux:2

# Install necessary dependencies
RUN yum update -y && \
    yum install -y python3 python3-pip && \
    pip3 install ansible docker

# Copy the Ansible playbook into the container
COPY playbook.yml /playbook.yml

# Run the Ansible playbook to set up the Minecraft server
RUN ansible-playbook /playbook.yml

# Expose the Minecraft server port
EXPOSE 25565

# Start the Minecraft server
CMD ["docker", "run", "-d", "-p", "25565:25565", "--name", "minecraft", "itzg/minecraft-server"]
