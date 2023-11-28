FROM alpine:edge
RUN apk add neovim git bash make gcc musl-dev
RUN mkdir /var/my-config
COPY . /var/my-config
RUN mkdir /src
RUN cd /var/my-config && chmod +x ./setup.sh && mkdir -p $HOME/.config/ && ./setup.sh
RUN nvim --headless -c "Lazy! restore" -c "quit"
WORKDIR /src
entrypoint "nvim"
