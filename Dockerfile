FROM python:3.10-slim

# Install bare-metal prerequisites for C++ compilation and ONNX parallel processing
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    libgl1 \
    libglib2.0-0 \
    libgomp1 \
    build-essential \
    ninja-build \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone the official TripoSR repository
RUN git clone https://github.com/VAST-AI-Research/TripoSR.git .

# Upgrade setuptools to strictly prevent torchmcubes compilation errors
RUN pip install --no-cache-dir --upgrade setuptools

# Pin PyTorch strictly to version 2.4.0 (CPU-only) 
# Modern transformers require 'torch.float8_e8m0fnu', which was introduced in PyTorch 2.4.0
RUN pip install --no-cache-dir torch==2.4.0+cpu torchvision==0.19.0+cpu torchaudio==2.4.0+cpu --index-url https://download.pytorch.org/whl/cpu

# DevOps Best Practice: Explicitly delete conflicting locks from upstream requirements
RUN sed -i '/transformers/d' requirements.txt && \
    sed -i '/gradio/d' requirements.txt

# Install dependencies and force stable, modern versions that are compatible with PyTorch 2.4.0
# Gradio 4.44.1 completely resolves the 'localhost not accessible' Docker routing bug
RUN pip install --no-cache-dir -r requirements.txt \
    "transformers==4.44.2" \
    "gradio==4.44.1" \
    onnxruntime

# Force Gradio to listen on all network interfaces inside the Docker container
ENV GRADIO_SERVER_NAME=0.0.0.0

EXPOSE 7860

# Entrypoint to start the Gradio application
CMD ["python", "gradio_app.py"]