#
# Github-Actions runner image.
#

FROM rodnymolina588/ubuntu-jammy-docker
LABEL maintainer="rodny.molina@docker.com"

ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
RUN mkdir -p /opt/hostedtoolcache

ARG GH_RUNNER_VERSION="2.322.0"

ARG TARGETPLATFORM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends dumb-init jq \
  && groupadd -g 121 runner \
  && useradd -mr -d /home/runner -u 1001 -g 121 runner \
  && usermod -aG sudo runner \
  && usermod -aG docker runner \
  && echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

WORKDIR /actions-runner

RUN curl -o actions-runner-linux-x64-2.322.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz && \
    echo "b13b784808359f31bc79b08a191f5f83757852957dd8fe3dbfcc38202ccf5768  actions-runner-linux-x64-2.322.0.tar.gz" | openssl dgst -sha256 -c && \
    tar xzf ./actions-runner-linux-x64-2.322.0.tar.gz && \
    rm -rf ./actions-runner-linux-x64-2.322.0.tar.gz

RUN adduser --disabled-password --gecos "" runner
RUN chown -R runner:runner /actions-runner
USER runner

# Register the runner
RUN ./config.sh --url https://github.com/AvenuProducts/jury-azure-onboarding --token BQE3KQAWSJKKRMPH72IDD5DIDR7EC --name terraform-runner --labels terraform-runner --replace 

CMD ["./run.sh"]