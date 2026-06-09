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
# Provides 'torch.float8_e8m0fnu' required by modern transformers
RUN pip install --no-cache-dir torch==2.4.0+cpu torchvision==0.19.0+cpu torchaudio==2.4.0+cpu --index-url https://download.pytorch.org/whl/cpu

# DevOps Best Practice: Explicitly delete conflicting locks from upstream requirements
RUN sed -i '/transformers/d' requirements.txt && \
    sed -i '/gradio/d' requirements.txt

# Install dependencies and force stable, modern versions
# Gradio 5.x explicitly fixes the 'bool is not iterable' Pydantic schema bug
RUN pip install --no-cache-dir -r requirements.txt \
    "transformers>=4.44.2" \
    "gradio>=5.0.0" \
    onnxruntime

# Crucial Docker Network Fixes for Gradio:
# 1. Listen on all external interfaces
ENV GRADIO_SERVER_NAME="0.0.0.0"
# 2. Fix the internal healthcheck ping (resolves 'localhost not accessible' crash)
ENV GRADIO_LOCALHOST_IP="127.0.0.1"
ENV NO_PROXY="localhost, 127.0.0.1, 0.0.0.0"
ENV no_proxy="localhost, 127.0.0.1, 0.0.0.0"

EXPOSE 7860

# Entrypoint to start the Gradio application
CMD ["python", "gradio_app.py"]