FROM ubuntu:latest

ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
RUN mkdir -p /opt/hostedtoolcache

ARG RUNNER_VERSION="2.322.0"
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates jq libicu67 \
    && groupadd -g 121 runner \
    && useradd -mr -d /home/runner -u 1001 -g 121 runner \
    && usermod -aG sudo runner \
    && usermod -aG docker runner \
    && echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

WORKDIR /home/runner

# Download and extract the runner
RUN curl -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" -o actions-runner.tar.gz \
    && tar -zxvf actions-runner.tar.gz \
    && rm actions-runner.tar.gz

# Install dependencies
RUN ./bin/installdependencies.sh

# Set ownership
RUN chown -R runner:runner /home/runner /opt/hostedtoolcache /_work

USER runner
WORKDIR /home/runner

ENTRYPOINT ["./run.sh"]
CMD ["--startuptype", "service"]