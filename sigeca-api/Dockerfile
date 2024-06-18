# Use the official Python image from the Docker Hub
FROM python:3.12-slim

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg \
    libc-dev \
    gcc \
    software-properties-common \
    libpq-dev \
    file && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Set environment variables
ENV PYTHONPATH=/app

# Copy application code
COPY . /app

# Run the app
WORKDIR /app
EXPOSE 8000
CMD ["fastapi", "run", "main.py"]
