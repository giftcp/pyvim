# ---- Stage 1: Source Image (where everything is already installed) ----
FROM python:lazy AS source

# ---- Stage 2: Target Image ----
FROM debian:bookworm-slim

# Install minimal dependencies if needed
RUN apt update && apt install -y \
  iputils-ping \
  gcc \
  && apt clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user (optional)
RUN useradd -ms /bin/bash appuser

# Copy Python from source
COPY --from=source /usr/bin/python3 /usr/bin/python3
COPY --from=source /usr/lib/python3.*/ /usr/lib/python3.*/
COPY --from=source /usr/include/python3.*/ /usr/include/python3.*/

# Copy Neovim binary
COPY --from=source /usr/bin/nvim /usr/bin/nvim

# Copy Neovim config and plugins
COPY --from=source /root/.config/nvim /home/appuser/.config/nvim
COPY --from=source /root/.local/share/nvim /home/appuser/.local/share/nvim

# Fix permissions
RUN chown -R appuser:appuser /home/appuser

# Set working directory and user
USER appuser
WORKDIR /home/appuser
ENV PATH="/usr/bin:$PATH"

# Start the HTTP server
CMD ["tail", "-f", "/dev/null"]
