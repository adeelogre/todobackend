FROM adeelvm/todobackend-base:latest

# Copy application artifacts
COPY target /wheelhouse

# Install application
RUN . /appenv/bin/activate && \
    pip install --no-index -f /wheelhouse todobackend && \
    rm -rf /wheelhouse

# Add application source
COPY src /application
WORKDIR /application