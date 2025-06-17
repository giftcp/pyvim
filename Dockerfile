# syntax=docker/dockerfile:1

############################
# Stage 1: Python base image
############################
ARG PYTHON_VERSION=3.12.4
FROM python:${PYTHON_VERSION}-slim AS python-base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
  python -m pip install -r requirements.txt

############################
# Stage 2: Neovim base image
############################
FROM anatolelucet/neovim:0.11.1 AS neovim-base

# Copy init.lua (or config) for plugin install
RUN mkdir -p /root/.config/nvim
COPY init.lua /root/.config/nvim/init.lua

# Install Neovim plugins at build time
RUN nvim --headless "+Lazy! sync" +qa

RUN ls /usr

############################
# Stage 3: Final image
############################
FROM python:${PYTHON_VERSION}-slim AS final

# Copy Python packages and app
COPY --from=python-base /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=python-base /usr/local/bin /usr/local/bin
# COPY --from=python-base /app /app

# Copy Neovim binary and config
COPY --from=neovim-base /usr/local/bin/nvim /usr/local/bin/nvim
# COPY --from=neovim-base /usr/share/nvim /usr/share/nvim
COPY --from=neovim-base /root/.config/nvim /root/.config/nvim

# Re-create user
ARG UID=10001
RUN adduser \
  --disabled-password \
  --gecos "" \
  --home "/nonexistent" \
  --shell "/sbin/nologin" \
  --no-create-home \
  --uid "${UID}" \
  appuser

WORKDIR /app
EXPOSE 8000
USER appuser

CMD ["python3", "-m", "http.server", "8000"]
