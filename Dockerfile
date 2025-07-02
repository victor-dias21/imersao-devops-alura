# syntax=docker/dockerfile:1

# Usamos uma imagem oficial e leve do Python baseada no Alpine.
FROM python:3.12-alpine

# Define variáveis de ambiente recomendadas para Python em contêineres.
# PYTHONUNBUFFERED: Garante que os logs sejam enviados diretamente para o terminal.
# PYTHONDONTWRITEBYTECODE: Impede a criação de arquivos .pyc.
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Cria um grupo e um usuário não-root por questões de segurança.
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Define o diretório de trabalho dentro do contêiner.
WORKDIR /app

# Copia o arquivo de dependências primeiro para aproveitar o cache do Docker.
# As dependências só serão reinstaladas se o requirements.txt mudar.
COPY requirements.txt .

# Instala as dependências do Python.
# --no-cache-dir reduz o tamanho da imagem ao não armazenar o cache do pip.
RUN pip install --no-cache-dir -r requirements.txt

# Copia o restante do código da aplicação para o diretório de trabalho.
# Isso garante que todos os módulos, como 'database.py', sejam incluídos.
COPY . .

# Define o usuário não-root para executar a aplicação.
USER appuser

# Expõe a porta que a aplicação usará (ajuste se necessário).
EXPOSE 3030

# Define o comando para iniciar a aplicação.
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "3030", "--reload"]
# O comando acima assume que o arquivo principal da aplicação é 'app.py' e que a instância do FastAPI é chamada 'app'.
