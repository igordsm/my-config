SHELL := /bin/bash
.ONESHELL:

INSTALL_DIR := $(HOME)/.local/bin
SRC_DIR     := $(HOME)/.local/src
export PATH := $(INSTALL_DIR):$(PATH)

# ── Platform detection ───────────────────────────────────────────────
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

ifeq ($(UNAME_S),Darwin)
  IS_MACOS := 1
  ifeq ($(UNAME_M),arm64)
    ZELLIJ_ASSET  := zellij-aarch64-apple-darwin.tar.gz
  else
    ZELLIJ_ASSET  := zellij-x86_64-apple-darwin.tar.gz
  endif
  NVIM_ASSET      := nvim-macos-$(if $(filter arm64,$(UNAME_M)),arm64,x86_64).tar.gz
  SHELL_RC        := $(HOME)/.zshrc
else
  IS_MACOS :=
  ifeq ($(UNAME_M),aarch64)
    ZELLIJ_ASSET  := zellij-aarch64-unknown-linux-musl.tar.gz
  else
    ZELLIJ_ASSET  := zellij-x86_64-unknown-linux-musl.tar.gz
  endif
  NVIM_ASSET      := nvim.appimage
  SHELL_RC        := $(HOME)/.bashrc
endif

.PHONY: install upgrade rust helix zellij neovim path

# ── Aggregate targets ────────────────────────────────────────────────
install: rust helix zellij neovim path

upgrade: helix zellij neovim

# ── Rust toolchain ───────────────────────────────────────────────────
rust: $(CARGO)

$(CARGO):
	@echo "==> Installing Rust toolchain..."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# ── Helix (mattwparas fork, steel-event-system) ──────────────────────
helix: | $(INSTALL_DIR)
	@echo "==> Building Helix from source..."
	@if [ -d "$(SRC_DIR)/helix" ]; then \
		cd "$(SRC_DIR)/helix" && \
		git fetch origin steel-event-system && \
		git checkout steel-event-system && \
		git pull --ff-only origin steel-event-system; \
	else \
		git clone --branch steel-event-system \
			https://github.com/mattwparas/helix.git "$(SRC_DIR)/helix"; \
	fi
		cd "$(SRC_DIR)/helix" && \
		cargo xtask steel --path helix-term --locked
	mkdir -p "$(HOME)/.config/helix"
	ln -sfn "$(SRC_DIR)/helix/runtime" "$(HOME)/.config/helix/runtime"

# ── Zellij (latest GitHub release) ───────────────────────────────────
zellij: | $(INSTALL_DIR)
	@echo "==> Installing Zellij..."
	$(eval ZELLIJ_VERSION := $(shell curl -sL https://api.github.com/repos/zellij-org/zellij/releases/latest | grep '"tag_name"' | cut -d'"' -f4))
	@echo "    Version: $(ZELLIJ_VERSION)"
	curl -sL "https://github.com/zellij-org/zellij/releases/download/$(ZELLIJ_VERSION)/$(ZELLIJ_ASSET)" \
		| tar xz -C "$(INSTALL_DIR)"
	chmod +x "$(INSTALL_DIR)/zellij"
ifdef IS_MACOS
	xattr -dr com.apple.quarantine "$(INSTALL_DIR)/zellij"
endif

# ── Neovim (latest GitHub release) ───────────────────────────────────
neovim: | $(INSTALL_DIR)
	@echo "==> Installing Neovim..."
ifdef IS_MACOS
	$(eval NVIM_TMPDIR := $(shell mktemp -d))
	curl -sL -o "$(NVIM_TMPDIR)/nvim.tar.gz" \
		"https://github.com/neovim/neovim/releases/latest/download/$(NVIM_ASSET)"
	tar xz -C "$(NVIM_TMPDIR)" -f "$(NVIM_TMPDIR)/nvim.tar.gz"
	rm -rf "$(INSTALL_DIR)/nvim-macos"
	mv "$(NVIM_TMPDIR)"/nvim-macos* "$(INSTALL_DIR)/nvim-macos"
	ln -sfn "$(INSTALL_DIR)/nvim-macos/bin/nvim" "$(INSTALL_DIR)/nvim"
	xattr -dr com.apple.quarantine "$(INSTALL_DIR)/nvim-macos"
	rm -rf "$(NVIM_TMPDIR)"
else
	curl -sL -o "$(INSTALL_DIR)/nvim" \
		"https://github.com/neovim/neovim/releases/latest/download/$(NVIM_ASSET)"
	chmod +x "$(INSTALL_DIR)/nvim"
endif

# ── Persist PATH in shell rc ────────────────────────────────────────
path:
	@if ! grep -q '\.local/bin' "$(SHELL_RC)" 2>/dev/null; then \
		echo 'export PATH="$$HOME/.local/bin:$$HOME/.cargo/bin:$$PATH"' >> "$(SHELL_RC)"; \
		echo "==> Added ~/.local/bin and ~/.cargo/bin to PATH in $(SHELL_RC)"; \
	fi

# ── Ensure install directory exists ──────────────────────────────────
$(INSTALL_DIR):
	mkdir -p $@

$(SRC_DIR):
	mkdir -p $@
