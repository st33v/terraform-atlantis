FROM golang:latest as builder
RUN CGO_ENABLED=0 go get -v github.com/carlpett/terraform-provider-sops
# RUN CGO_ENABLED=0 go get -v github.com/daryl-d/terraform-provider-cassandra
# RUN CGO_ENABLED=0 go get -v github.com/Mongey/terraform-provider-kafka
# RUN go get -v github.com/infobloxopen/terraform-provider-infoblox

FROM runatlantis/atlantis:v0.7.2
LABEL maintainer="Steve Neuharth<steve@aethereal.io>"

# Install base and dev packages
RUN apk update && apk add --no-cache --virtual .build-deps && apk add bash jq make curl openssh git groff less python py-pip

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Install aws-cli
RUN pip install awscli
RUN mkdir -p /root/.terraform.d/plugins /home/atlantis/.terraform.d/plugins
RUN wget https://github.com/mozilla/sops/releases/download/3.2.0/sops-3.2.0.linux
RUN mv sops-3.2.0.linux /usr/local/bin/sops; chmod +x /usr/local/bin/sops
# Copy providers
COPY --from=builder /go/bin/terraform-* /root/.terraform.d/plugins/
COPY --from=builder /go/bin/terraform-* /home/atlantis/.terraform.d/plugins/
