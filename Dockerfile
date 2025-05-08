FROM openjdk:21-slim-bullseye

RUN apt-get update && apt-get install -y curl tar libicu-dev jq ca-certificates curl ant

RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && apt-get update

RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin fuse-overlayfs

WORKDIR /actions-runner

RUN curl -o actions-runner-linux-x64-2.322.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz && \
    echo "b13b784808359f31bc79b08a191f5f83757852957dd8fe3dbfcc38202ccf5768  actions-runner-linux-x64-2.322.0.tar.gz" | openssl dgst -sha256 -c && \
    tar xzf ./actions-runner-linux-x64-2.322.0.tar.gz && \
    rm -rf ./actions-runner-linux-x64-2.322.0.tar.gz

ENV RUNNER_ALLOW_RUNASROOT="1"

# Register the runner
RUN ./config.sh -y --url https://github.com/AvenuProducts --token BQE3KQEJ53CQSDGDND4HIADIDR42C --name java-runner --labels java-runner --replace
    
# Copy entrypoint script
CMD ["./run.sh"]