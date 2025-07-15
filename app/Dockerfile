# Imagen base
FROM python:3.11-slim

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Exponer puerto
EXPOSE 5000

# Comando para correr la app
CMD ["python", "app.py"]
