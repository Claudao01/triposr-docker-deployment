FROM python:3.10-slim

# Install bare-metal prerequisites for C++ compilation and ONNX parallel processing
RUN apt-get update && apt-get install -y \
    git curl wget libgl1 libglib2.0-0 libgomp1 \
    build-essential ninja-build python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone the official TripoSR repository
RUN git clone https://github.com/VAST-AI-Research/TripoSR.git .

# Upgrade build tools to strictly prevent torchmcubes compilation errors
RUN pip install --no-cache-dir --upgrade setuptools pip

# 1. Freeze PyTorch to version 2.2.2 (CPU-only) to guarantee absolute stability
RUN pip install --no-cache-dir torch==2.2.2+cpu torchvision==0.17.2+cpu torchaudio==2.2.2+cpu --index-url https://download.pytorch.org/whl/cpu

# 2. Strip strict version locks from original requirements to allow clean resolution
RUN sed -i '/transformers/d' requirements.txt && \
    sed -i '/gradio/d' requirements.txt && \
    sed -i '/huggingface-hub/d' requirements.txt

# 3. Install a conflict-free, modern matrix
# - transformers 4.39.3 avoids PyTorch 2.4.0 dependencies and float8 bugs
# - gradio 5+ fixes the Pydantic/FastAPI "bool is not iterable" schema bug
RUN pip install --no-cache-dir -r requirements.txt \
    "transformers==4.39.3" \
    "gradio>=5.0.0" \
    onnxruntime

# 4. Network configurations to bypass Docker proxy issues
ENV GRADIO_SERVER_NAME="0.0.0.0"
ENV no_proxy="localhost, 127.0.0.1, 0.0.0.0"
ENV NO_PROXY="localhost, 127.0.0.1, 0.0.0.0"

EXPOSE 7860

# 5. CRITICAL FIX: The TripoSR gradio_app.py requires the --listen flag to bind to 0.0.0.0
CMD ["python", "gradio_app.py", "--listen"]