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

# Freeze PyTorch to version 2.2.2 (CPU-only) to match the TripoSR release era
RUN pip install --no-cache-dir torch==2.2.2+cpu torchvision==0.17.2+cpu torchaudio==2.2.2+cpu --index-url https://download.pytorch.org/whl/cpu

# Time-Freeze Architecture 2.0:
# 1. We keep original requirements (transformers==4.35.0).
# 2. Pin gradio==3.50.2 to prevent PIP backtracking and conflicting with tokenizers < 0.17.
# 3. Inject Jinja2==3.1.3 to fix the known "unhashable type: dict" bug in Gradio 3.x.
# 4. Inject onnxruntime for rembg background removal.
RUN pip install --no-cache-dir -r requirements.txt \
    "gradio==3.50.2" \
    "Jinja2==3.1.3" \
    onnxruntime

# Force Gradio to listen on all network interfaces inside the Docker container
ENV GRADIO_SERVER_NAME=0.0.0.0

EXPOSE 7860

# Entrypoint to start the Gradio application
CMD ["python", "gradio_app.py"]