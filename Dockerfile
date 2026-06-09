FROM python:3.10-slim

# Install bare-metal prerequisites and C++ compilers
# Note: libgl1 is sufficient; libgl1-mesa-glx is obsolete in modern Debian
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

# Upgrade setuptools to prevent torchmcubes compilation errors
RUN pip install --no-cache-dir --upgrade setuptools

# Pin PyTorch strictly to version 2.3.1 (CPU-only)
# This prevents 'float8_e8m0fnu' attribute errors caused by bleeding-edge torch updates
RUN pip install --no-cache-dir torch==2.3.1+cpu torchvision==0.18.1+cpu torchaudio==2.3.1+cpu --index-url https://download.pytorch.org/whl/cpu

# DevOps Best Practice: Explicitly delete conflicting locks from upstream requirements
RUN sed -i '/transformers/d' requirements.txt && \
    sed -i '/gradio/d' requirements.txt

# Install dependencies with STRICT VERSION PINNING to avoid breaking changes in bleeding-edge releases
# Matching a stable matrix: PyTorch 2.3.1 + Transformers 4.41.2 + Gradio 4.44.1
RUN pip install --no-cache-dir -r requirements.txt \
    "transformers==4.41.2" \
    "gradio==4.44.1" \
    onnxruntime

# Force Gradio to listen on all network interfaces inside the container
ENV GRADIO_SERVER_NAME=0.0.0.0

EXPOSE 7860

# Entrypoint to start the Gradio application
CMD ["python", "gradio_app.py"]