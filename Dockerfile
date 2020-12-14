FROM alpine:latest

LABEL name=aws-devops

ARG TERRAFORM_VERSION=0.13.5
ARG TERRAGRUNT_VERSION=0.26.7
ARG PACKER_VERSION=1.6.5
ARG TFLINT_VERSION=0.22.0
ARG TFSEC_VERSION=0.21.0

ENV TF_PLUGIN_CACHE_DIR=/opt/terraform/plugins

RUN \
  apk --no-cache add \
    ansible \
    bash \
    bash-completion \
    curl \
    groff \
    git \
    jq \
    less \
    libc6-compat \
    make \
    openssh-client \
    python3 \
    py3-pip \
    py3-crcmod \
    tree \
    vim \
    wget \
    unzip \
    zip \
    && \
  \
  pip3 install --upgrade pip && \
  \
  pip3 install --upgrade awscli s3cmd && \
  pip3 install --upgrade pytest && \
  \
  wget -q -O /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
  chmod +x /tmp/kubectl && \
  mv /tmp/kubectl /usr/local/bin && \
  \
  # Cleanup \
  rm -rf /tmp/* && \
  rm -rf /var/cache/apk/* && \
  rm -rf /var/tmp/*

RUN \
  wget -q -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip -q /tmp/terraform.zip -d /tmp && \
  chmod +x /tmp/terraform && \
  mv /tmp/terraform /usr/local/bin && \
  \
  wget -qO /tmp/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
  chmod +x /tmp/terragrunt && \
  mv /tmp/terragrunt /usr/local/bin && \
  \
  wget -qO /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip && \
  unzip -q /tmp/tflint.zip -d /tmp && \
  chmod +x /tmp/tflint && \
  mv /tmp/tflint /usr/local/bin && \
  \
  wget -qO /tmp/tfsec https://github.com/liamg/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64 && \
  chmod +x /tmp/tfsec && \
  mv /tmp/tfsec /usr/local/bin && \
  \
  wget -qO /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
  unzip -q /tmp/packer.zip -d /tmp && \
  chmod +x /tmp/packer && \
  mv /tmp/packer /usr/local/bin && \
  \
  mkdir -p ${TF_PLUGIN_CACHE_DIR}/linux_amd64 && \
  ansible --version && \
  aws --version && \
  kubectl version --client && \
  python3 --version && \
  terraform version && \
  terragrunt -version && \
  tflint --version && \
  tfsec --version && \
  packer version

# Customisations
COPY *.sh /tmp/
RUN \
  adduser -Ds /bin/bash devops && \
  \
  . /tmp/10-terraform-providers.sh && \
  chmod -R 777 ${TF_PLUGIN_CACHE_DIR} && \
  \
  . /tmp/20-bashrc.sh && \
  \
  # Cleanup \
  rm -rf /tmp/* && \
  rm ~/.wget-hsts

ENTRYPOINT ["/bin/bash"]
