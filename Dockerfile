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

# Freeze PyTorch to version 2.2.2 (CPU-only) 
# This matches the exact era of the TripoSR release and prevents breaking changes from PyTorch 2.4+
RUN pip install --no-cache-dir torch==2.2.2+cpu torchvision==0.17.2+cpu torchaudio==2.2.2+cpu --index-url https://download.pytorch.org/whl/cpu

# Time-Freeze Architecture: 
# 1. Install original requirements exactly as the authors intended.
# 2. Inject 'onnxruntime' (missing in the original repo, required by rembg).
# 3. Inject 'Jinja2==3.1.3' (Antidote: Fixes the 'unhashable type: dict' crash in Gradio 4.8.0).
# 4. Inject 'huggingface-hub==0.20.3' (Antidote: Satisfies transformers 4.35 constraints without upgrading to 1.x).
RUN pip install --no-cache-dir -r requirements.txt \
    onnxruntime \
    Jinja2==3.1.3 \
    huggingface-hub==0.20.3

# Force Gradio to listen on all network interfaces inside the Docker container
ENV GRADIO_SERVER_NAME=0.0.0.0

EXPOSE 7860

# Entrypoint to start the Gradio application
CMD ["python", "gradio_app.py"]