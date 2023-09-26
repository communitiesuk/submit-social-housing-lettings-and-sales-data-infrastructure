FROM alpine:latest
RUN apk add postgresql

# The 'apk add cloudfoundry-cli' command doesn't work, so we do something similar to the 'download examples with curl' instructions at the link below:
# https://github.com/cloudfoundry/cli/blob/main/doc/installation-instructions/installation-instructions-v7.md
RUN apk update && apk add curl && curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=v7&source=github" | tar -zx -C /usr/local/bin
RUN chmod +x /usr/local/bin/cf

RUN cf install-plugin conduit -f

COPY ./run.sh ./run.sh

CMD ["sh", "/run.sh"]
