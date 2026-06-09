FROM python:3.10-slim

# Install system dependencies and C++ compilers for torchmcubes
RUN apt-get update && apt-get install -y \
    git \
    libgl1 \
    libglib2.0-0 \
    build-essential \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone the official TripoSR repository
RUN git clone https://github.com/VAST-AI-Research/TripoSR.git .

# Install PyTorch optimized ONLY for CPU
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Install model dependencies and web interface
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir "gradio>=4.44.1" onnxruntime "huggingface-hub<1.0"

# Force Gradio to listen on all network interfaces
ENV GRADIO_SERVER_NAME=0.0.0.0

EXPOSE 7860

CMD ["python", "gradio_app.py"]