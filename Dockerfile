FROM python:3.10-slim

WORKDIR /app

# On copie TOUT le dossier d'un coup. Comme ça, Docker prend obligatoirement 
# le requirements.txt et le dossier templates sans se poser de questions.
COPY . .

# On installe les dépendances
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]