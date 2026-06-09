FROM python:3.10-slim

# Install bare-metal prerequisites and C++ compilers for torchmcubes and ONNX
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

# Upgrade setuptools as strictly recommended by the official TripoSR documentation
# This prevents compilation errors when building torchmcubes without CUDA
RUN pip install --no-cache-dir --upgrade setuptools

# Install PyTorch optimized strictly for CPU
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Overwrite outdated version locks to prevent dependency conflicts (e.g., huggingface-hub vs transformers)
RUN sed -i 's/transformers==4.35.0/transformers>=4.40.0/' requirements.txt && \
    sed -i 's/gradio/gradio>=4.44.1/' requirements.txt

# Install all model dependencies, web interface, and ONNX runtime in a single pass
RUN pip install --no-cache-dir -r requirements.txt onnxruntime

# Force Gradio to listen on all network interfaces inside the container
ENV GRADIO_SERVER_NAME=0.0.0.0

EXPOSE 7860

# Entrypoint to start the Gradio application
CMD ["python", "gradio_app.py"]