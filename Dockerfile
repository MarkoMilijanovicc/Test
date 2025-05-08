FROM debian:stable-slim

RUN apt-get update && apt-get install -y curl tar libicu-dev gnupg software-properties-common wget jq

# Install Terraform
WORKDIR /terraform

RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list

RUN apt-get update && \
    apt-get -y install terraform

# Install Azure CLI
WORKDIR /azure-cli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install GitHub runner
WORKDIR /actions-runner

RUN curl -o actions-runner-linux-x64-2.322.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz && \
    echo "b13b784808359f31bc79b08a191f5f83757852957dd8fe3dbfcc38202ccf5768  actions-runner-linux-x64-2.322.0.tar.gz" | openssl dgst -sha256 -c && \
    tar xzf ./actions-runner-linux-x64-2.322.0.tar.gz && \
    rm -rf ./actions-runner-linux-x64-2.322.0.tar.gz

RUN adduser --disabled-password --gecos "" runner
RUN chown -R runner:runner /actions-runner
USER runner

# Register the runner
RUN ./config.sh --url https://github.com/AvenuProducts/jury-azure-onboarding --token BQE3KQDZSD7ZY673FWBM5NDIDSFMK --name terraform-runner --labels terraform-runner --replace 

CMD ["./run.sh"]
