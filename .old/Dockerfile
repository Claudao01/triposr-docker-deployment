FROM python:3.10-slim

# Instala dependências do sistema essenciais para processamento de imagem e 3D
# Atualizado para o pacote libgl1 compatível com o Debian mais recente
RUN apt-get update && apt-get install -y \
    git \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clona o repositório oficial do TripoSR
RUN git clone https://github.com/VAST-AI-Research/TripoSR.git .

# Instala o PyTorch otimizado APENAS para CPU (evita baixar os gigabytes do CUDA)
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Instala as dependências do modelo e a interface web
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gradio

# Força o Gradio a escutar todas as interfaces de rede do container
ENV GRADIO_SERVER_NAME=0.0.0.0

EXPOSE 7860

CMD ["python", "app.py"]